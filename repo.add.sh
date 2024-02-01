#!/usr/bin/bash -e
#
# Adding repository in Packagist.
#
# @package    Bash
# @author     Kai Kimera <mail@kai.kim>
# @copyright  2023 iHub TO
# @license    MIT
# @version    0.0.1
# @link       https://lib.onl
# -------------------------------------------------------------------------------------------------------------------- #

(( EUID == 0 )) && { echo >&2 'This script should not be run as root!'; exit 1; }

# -------------------------------------------------------------------------------------------------------------------- #
# CONFIGURATION.
# -------------------------------------------------------------------------------------------------------------------- #

curl="$( command -v curl )"
sleep='2'

# Help.
read -r -d '' help <<- EOF
Options:
  -x 'TOKEN'                            Packagist token.
  -u 'USER'                             Packagist user name.
  -r 'URL_1;URL_2;URL_3'                Repository URL (array).
EOF

# -------------------------------------------------------------------------------------------------------------------- #
# OPTIONS.
# -------------------------------------------------------------------------------------------------------------------- #

OPTIND=1

while getopts 'x:u:r:h' opt; do
  case ${opt} in
    x)
      token="${OPTARG}"
      ;;
    u)
      user="${OPTARG}"
      ;;
    r)
      repos="${OPTARG}"; IFS=';' read -ra repos <<< "${repos}"
      ;;
    h|*)
      echo "${help}"; exit 2
      ;;
  esac
done

shift $(( OPTIND - 1 ))

(( ! ${#repos[@]} )) && { echo >&2 '[ERROR] Repository URL not specified!'; exit 1; }
[[ -z "${token}" ]] && { echo >&2 '[ERROR] Packagist token not specified!'; exit 1; }
[[ -z "${user}" ]] && { echo >&2 '[ERROR] Packagist user name not specified!'; exit 1; }

# -------------------------------------------------------------------------------------------------------------------- #
# INITIALIZATION.
# -------------------------------------------------------------------------------------------------------------------- #

init() {
  repo_add
}

# -------------------------------------------------------------------------------------------------------------------- #
# PACKAGIST: ADD REPOSITORY.
# -------------------------------------------------------------------------------------------------------------------- #

repo_add() {
  for repo in "${repos[@]}"; do
    echo '' && echo "--- OPEN: '${repo}'"

    ${curl} -X POST \
      -H 'Content-Type: application/json' \
      "https://packagist.org/api/create-package?username=${user}&apiToken=${token}" \
      -d @- << EOF
{
  "repository": {
    "url": "${repo}"
  }
}
EOF

    echo '' && echo "--- DONE: '${repo}'" && echo ''; sleep ${sleep}
  done
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< INIT FUNCTIONS >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

init "$@"; exit 0
