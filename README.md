# FLOSS Application GitHub Template

A general-purpose GitHub repository template that's ready for Inspired Beings FLOSS (Free, Libre, and Open-Source Software) applications.

## Features

- **License**
  - [GNU Affero General Public License](https://www.gnu.org/licenses/why-affero-gpl.html): 
    - Ensures code can be used in commercial projects but any changes must be open-sourced.
- **Community Standards**
  - Includes all the [recommended Community Standards files](https://opensource.guide) for open-source projects.
- **Trademark Policy**
  - A forks-must-rename policy protecting application names and the "FLOSS" collection branding,
    since the AGPL covers copyright, not naming.
- **GitHub Actions Workflow**
  - A self-deleting workflow amending the default "Initial commit" message
    with a [Conventional Commit](https://www.conventionalcommits.org) one: `feat: initialize project`.
- **DCO Enforcement**
  - A workflow requiring a `Signed-off-by` line ([Developer Certificate of Origin](https://developercertificate.org))
    on every pull request commit.
- **EditorConfig**
  - An [EditorConfig](https://editorconfig.org) file following most common coding standards.
- **Renovate**
  - A customized [Renovate](https://github.com/renovatebot/renovate) configuration file
    for automated dependency management.
