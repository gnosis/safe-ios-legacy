=============
Localization
=============

To localize a string that is used in the UI, please use our project-specific wrapper for localized strings:

    LocalizedString("localization_key", comment: "Comment for the string's purpose")

We have a convention of putting all of the localized strings together as a ``private enum Strings`` 
that has static constants. Of course, if access to the strings is needed from the unit tests, then
the access modifier is ``internal``.

For example::

    public class TermsAndConditionsViewController: UIViewController {

        // ... 

        private enum Strings {
            static let header = LocalizedString("onboarding.terms.header", comment: "Header label")
            static let termsLink = LocalizedString("onboarding.terms.terms", comment: "Terms of Use")
            static let disagree = LocalizedString("onboarding.terms.disagree", comment: "No Thanks")
        }

        // ...
    }

The "Localized.strings" file are updated automatically on every build, so after you introduced new
keys, removed an old key from the source, or updated them, the previously existing keys will be replaced with new ones.

.. important::
    If you just want to change a key and keep the translation intact, do not hit the "Build" action in
    Xcode because it will remove your old key with its translation completely. Instead, search and replace
    all occurrences of the old key with the new one.

After you changed or introduced new keys, build the project to update the ``Localizable.strings`` files in the project, and then pull translations from the translation system. We use https://lokalise.co/. 

To pull the translations, run the ``translate`` lane from command line::

    bundle exec fastlane translate

Make sure you have the configuration keys in place by  providing appropriate ``.env.default`` configuration file variables ``LOKALISE_TOKEN`` and ``LOKALISE_PROJECT_ID``.
