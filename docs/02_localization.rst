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
