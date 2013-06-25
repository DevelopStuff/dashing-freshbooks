dashing-freshbooks
========
An instance of [dashing](http://shopify.github.com/dashing) that hooks up to your Freshbooks account. Useful for "motivation" (read: shaming).

install
=======
    $> hub fork DevelopStuff/dashing-freshbooks
    $> bundle install
    $> heroku apps:create
    $> heroku config:set FRESHBOOKS_ENDPOINT=http://pathtoyour.freshbooks.com
    $> heroku config:set FRESHBOOKS_TOKEN=yoursupersecretAPItoken
    $> heroku config:set AUTH_TOKEN=yoursupersecretAUTHTOKEN
    $> git add Gemfile.lock
    $> git commit -m "Added Gemfile.lock for Heroku push"
    $> git push heroku master
    $> heroku open

Check out http://shopify.github.com/dashing for more information.