dashing-freshbooks
========
An instance of [dashing](http://shopify.github.com/dashing) that hooks up to your Freshbooks account. Useful for "motivation" (read: shaming).

install
=======
    $> hub fork DevelopStuff/dashing-freshbooks
    $> heroku apps:create
    $> heroku config:set FRESHBOOKS_ENDPOINT=http://pathtoyour.freshbooks.com
    $> heroku config:set FRESHBOOKS_TOKEN=yoursupersecretAPItoken
    $> heroku config:set AUTH_TOKEN=yoursupersecretAUTHTOKEN
    $> git push heroku master
    $> heroku open

Check out http://shopify.github.com/dashing for more information.