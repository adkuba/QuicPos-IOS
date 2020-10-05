# QuicPos-IOS
QuicPos client IOS application. SwiftUI

## App notes
App needs to check if userId is not null during post downloading. Display post get error if there is no internet connection!

## XCode-Swift notes
- Sometimes you need to log in again to Apple account: Xcode -> Preference -> Accounts
- Im using SwiftUI [great tutorial](https://developer.apple.com/tutorials/swiftui/composing-complex-interfaces), **it's all based on views like components in Vue, you combine them and switch between**

## Apollo usage
- download schema from your QraphQL server [tutorial](https://www.apollographql.com/docs/ios/tutorial/tutorial-obtain-schema/) -> project settings - target - build phases - (add ApolloCLI build phase)
```
# Go to the build root and search up the chain to find the Derived Data Path where the source packages are checked out.
DERIVED_DATA_CANDIDATE="${BUILD_ROOT}"

while ! [ -d "${DERIVED_DATA_CANDIDATE}/SourcePackages" ]; do
  if [ "${DERIVED_DATA_CANDIDATE}" = / ]; then
    echo >&2 "error: Unable to locate SourcePackages directory from BUILD_ROOT: '${BUILD_ROOT}'"
    exit 1
  fi

  DERIVED_DATA_CANDIDATE="$(dirname "${DERIVED_DATA_CANDIDATE}")"
done

# Grab a reference to the directory where scripts are checked out
SCRIPT_PATH="${DERIVED_DATA_CANDIDATE}/SourcePackages/checkouts/apollo-ios/scripts"

if [ -z "${SCRIPT_PATH}" ]; then
    echo >&2 "error: Couldn't find the CLI script in your checked out SPM packages; make sure to add the framework to your project."
    exit 1
fi

cd "${SRCROOT}/${TARGET_NAME}"
"${SCRIPT_PATH}"/run-bundled-codegen.sh codegen:generate --target=swift --includes=./**/*.graphql --localSchemaFile="schema.json" API.swift
#"${SCRIPT_PATH}"/run-bundled-codegen.sh schema:download --endpoint="http://192.168.8.106:8080/query"
```
Commented last line downloads schema from endpoint, line before creates API.swift from downloaded schema. First download then generate! Remember to add files to your project, only API.swift must be included in app package.
- create Network.swift - basic Apollo client
- example data fetch in ContentView.swift - I hope it's implemented correctly

## Swift notes
[About async wait functions](https://stackoverflow.com/questions/42484281/waiting-until-the-task-finishes/42484670)
