require 'ruby-freshbooks'
require 'active_support/core_ext/date/calculations.rb'
require 'active_support/core_ext/date_time/calculations.rb'

DATE_FORMAT = '%F %T'
PER_PAGE = 100

# :first_in sets how long it takes before the job is first run. In this case, it is run immediately
SCHEDULER.every '10m', :first_in => 0 do |job|
  client = FreshBooks::Client.new(ENV['FRESHBOOKS_ENDPOINT'], ENV['FRESHBOOKS_TOKEN'])
  
  # Projects
  r = client.project.list(:per_page => PER_PAGE)
  l = r["projects"]["project"].is_a?(Hash) ? [r["projects"]["project"]] : r["projects"]["project"]
  projects = {}
  l.each{|p| projects[p["project_id"]] = { :name => p["name"], :rate => p["rate"]} }
  
  r = client.time_entry.list(:per_page => PER_PAGE, :date_from => DateTime.now.utc.at_beginning_of_week.strftime(DATE_FORMAT), :date_to => DateTime.now.utc.strftime(DATE_FORMAT))
  weekly_time_entries = r["time_entries"]["time_entry"].is_a?(Hash) ? [r["time_entries"]["time_entry"]] : r["time_entries"]["time_entry"]
  
  # Week so far
  week_so_far_hours = 0
  week_so_far_hours = weekly_time_entries.collect{|e| e["hours"].to_f }.inject(:+)
  
  week_so_far_money = 0.0
  week_so_far_money = weekly_time_entries.collect{|e| (e["hours"].to_f * projects[e["project_id"]][:rate].to_f) }.inject(:+)
  
  week_money_by_project = {}
  weekly_time_entries.each do |e|
    week_money_by_project[e["project_id"]] ||= { :label => projects[e["project_id"]][:name], :value => 0.0 }
    week_money_by_project[e["project_id"]][:value] += (e["hours"].to_f * projects[e["project_id"]][:rate].to_f)
  end
  
  # Year paid/unpaid
  r = client.payment.list(:per_page => PER_PAGE, :date_from => DateTime.now.utc.beginning_of_year.strftime(DATE_FORMAT), :date_to => DateTime.now.utc.end_of_year.strftime(DATE_FORMAT))
  pages = r["payments"]["pages"].to_i
  payments = r["payments"]["payment"].is_a?(Hash) ? [r["payments"]["payment"]] : r["payments"]["payment"]
  payments ||= []
  if (pages > 1)
    page = 2
    while(page <= pages)
      r = client.payment.list(:page => page, :per_page => PER_PAGE, :date_from => DateTime.now.utc.beginning_of_year.strftime(DATE_FORMAT), :date_to => DateTime.now.utc.end_of_year.strftime(DATE_FORMAT))
      more = r["payments"]["payment"].is_a?(Hash) ? [r["payments"]["payment"]] : r["payments"]["payment"]
      payments += more
      page += 1
    end
  end
  
  r = client.invoice.list(:per_page => PER_PAGE, :status => 'unpaid', :date_from => DateTime.now.utc.beginning_of_year.strftime(DATE_FORMAT), :date_to => DateTime.now.utc.end_of_year.strftime(DATE_FORMAT))
  pages = r["invoices"]["pages"].to_i
  invoices = r["invoices"]["invoice"].is_a?(Hash) ? [r["invoices"]["invoice"]] : r["invoices"]["invoice"]
  invoices ||= []
  if (pages > 1)
    page = 2
    while(page <= pages)
      r = client.payment.list(:page => page, :per_page => PER_PAGE, :date_from => DateTime.now.utc.beginning_of_year.strftime(DATE_FORMAT), :date_to => DateTime.now.utc.end_of_year.strftime(DATE_FORMAT))
      more = r["invoices"]["invoice"].is_a?(Hash) ? [r["invoices"]["invoice"]] : r["invoices"]["invoice"]
      invoices += more
      page += 1
    end
  end
  
  
  year_paid = payments.collect{|p| p["amount"].to_f }.inject(:+)
  year_unpaid = invoices.collect{|i| i["amount"].to_f }.inject(:+)
  
  send_event('week_so_far_hours', { :value =>  week_so_far_hours })
  send_event('week_so_far_money', { :current => week_so_far_money })
  send_event('week_money_by_project', { :items => week_money_by_project.values } )
  send_event('year_paid', { :current => year_paid })
  send_event('year_unpaid', { :current => year_unpaid })
end