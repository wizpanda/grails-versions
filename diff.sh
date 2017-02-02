#!/bin/bash -e

rm -rf .git versions/
git init .
git add .
git commit -am 'Initial commit'
git remote add origin git@github.com:erichelgeson/grails-versions.git
git push origin master -f

export SDKMAN_DIR="$HOME/.sdkman" && source "$HOME/.sdkman/bin/sdkman-init.sh"

function diffProfileVersion() {
    echo "Generating diff for profile $2"
    grails create-app $1 --profile=$2
    cd $1
    ./gradlew dependencyManagement > dependencyManagement.txt
    cd ..
    git add $1
}

function diffVersion() {
    sdk use grails $1
    echo "Generating diff for Grails $1"
    diffProfileVersion versions web
    diffProfileVersion rest-api-versions rest-api
    git commit -a -m $1
    git tag $1
    rm -rf versions rest-api-versions
}

# Initial version to diff from
diffVersion 3.0.0

# 3.0.x
for i in $(seq 1 17); do
    diffVersion 3.0.$i
done

# 3.1.x
for i in $(seq 0 15); do
   diffVersion 3.1.$i
done

# 3.2.x
for i in $(seq 0 5); do
   diffVersion 3.2.$i
done

git push origin master -f
git push origin --tags -f
