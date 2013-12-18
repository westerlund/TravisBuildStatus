Menu bar app to display travis last build
=========================================

Make sure you add the following lines in your .travis.yml in the repo you want to hook:

    notifications:
      webhooks:
        - http://simonwesterlund.se/travis.php
