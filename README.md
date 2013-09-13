BookApp
=======

A gamebook app framework based on Corona SDK and Twine.

- - - - - - - - - - - - -

This framework will allow you to quickly create your own gamebooks (where you choose 
your own path through the story) and deploy them into an app.  The framework uses
the Corona SDK, so you can create Android, iPhone, Ouya, and other formats (and
sell them in app stores if you wish).

The general workflow:

* Use Twine to create the text for the book, including the standard
Twine macros.  
* From within Twine, you can edit single passages and also see the overall structure
of your story (what passages link to other).
* When you're ready, just export the file to text (File menu, "Export source code") 
and put that in the 'assets' folder in the framework.
* Use that inside a Corona simulator to view and test the app with different screen
sizes.
* When you're ready, "Build" the app from within Corona and the system will send
you a read-to-deploy app package (e.g. apk file for Android).
* For Android, you can transfer the apk to a real device and install it for further
device-specific testing.
* Or you can upload that package to an app store and away you go!

- - - - - - - - - - - - -

Twine:
	http://gimcrackd.com/etc/src/

Corona:
	http://coronalabs.com/

