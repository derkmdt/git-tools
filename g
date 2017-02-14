#!/bin/bash

if [ ! -z $1 ]
then
  option=$1
else
  echo "pur - Pull (with rebase)";
  echo "mfm - Merge From Master on current branch";
  echo "mfm-theirs - Merge From Master on current branch, in favor of their changes";
  echo "ps  - Push";
  echo "uar  - Update All Repos recursively";
  echo "Select your option:"
  read option
fi


function doStash() {
  if [ $1 == "1" ]
  then
    git stash
  fi
}

function doPop() {
  if [ $1 == "1" ]
  then
    git stash pop
  fi
}

function showHeader() {
  echo ""
  echo $1
}


case $option in
uar)
  # store the current dir
  CUR_DIR=$(pwd)

  # Let the person running the script know what's going on.
  showHeader "uar: Pulling in latest changes for all repositories..."

  # Find all git repositories and update it to the master latest revision
  for i in $(find . -name ".git" | cut -c 3-); do

    # We have to go to the .git parent directory to call the pull command
    cd "$i";
    cd ..;

    current_branch=`git rev-parse --abbrev-ref HEAD`

    # call the Is Stash Required function
    bash ~/isr
    stash_required=$?

    doStash $stash_required;

    if [ "$current_branch" != 'master' ]
    then
      git checkout master
      git pull --rebase
      git checkout $current_branch
    else
      git pull --rebase
    fi

    doPop $stash_required;

    # lets get back to the CUR_DIR
    cd $CUR_DIR
  done

  echo "Complete!"
  ;;
pur)
  showHeader "pur: git pull --rebase"
  bash ~/isr
  stash_required=$?

  doStash $stash_required;

  git pull --rebase

  doPop $stash_required;
  ;;
mfm)
  showHeader "mfm: Merge master on current branch"
  current_branch=`git rev-parse --abbrev-ref HEAD`
  bash ~/isr
  stash_required=$?

  doStash $stash_required;

  if [ $current_branch != 'master' ]
  then
    git checkout master
    git pull --rebase
    git checkout $current_branch
    git merge master
  else
    echo "Already on master - not rebasing."
  fi
  doPop $stash_required;
  ;;
mfm-theirs)
  showHeader "mfm: Merge master on current branch, favor theirs"
  current_branch=`git rev-parse --abbrev-ref HEAD`
  bash ~/isr
  stash_required=$?

  doStash $stash_required;

  if [ $current_branch != 'master' ]
  then
    git checkout master
    git pull --rebase
    git checkout $current_branch
    git merge master
  else
    echo "Already on master - not rebasing."
  fi
  doPop $stash_required;
  ;;
ps)
  showHeader "ps: Push"
  stash_required=$( doIsr; );

  doStash $stash_required;

  git push

  doPop $stash_required;
  ;;
*)
  echo "Option invalid"
  ;;
esac
