#!/bin/bash

if [ ! -z $1 ]
then
  option=$1
else
  echo "pur - Pull (with rebase)";
  echo "mfm - Merge From Master on current branch";
  echo "mfm-theirs - Merge From Master on current branch, in favor of their changes";
  echo "ps  - Push";
  echo "Select your option:"
  read option
fi

isr
stash_required=$?

current_branch=`git rev-parse --abbrev-ref HEAD`

function doStash() {
  if [ $stash_required == "1" ]
  then
    git stash
  fi
}

function doPop() {
  if [ $stash_required == "1" ]
  then
    git stash pop
  fi 
}

function showHeader() {
  echo ""
  echo $1
}


case $option in
pur)
  showHeader "pur: git pull --rebase"
  doStash;

  git pull --rebase

  doPop;
  ;;
mfm)
  showHeader "mfm: Merge master on current branch"
  doStash;
  
  if [ $current_branch != 'master' ]
  then
    git checkout master
    git pull --rebase
    git checkout $current_branch
    git merge master
  else
    echo "Already on master - not rebasing."
  fi
  doPop;
  ;;
mfm-theirs)
  showHeader "mfm: Merge master on current branch, favor theirs"
  doStash;
  
  if [ $current_branch != 'master' ]
  then
    git checkout master
    git pull --rebase
    git checkout $current_branch
    git merge master
  else
    echo "Already on master - not rebasing."
  fi
  doPop;
  ;;
ps)
  showHeader "ps: Push"
  doStash;
  
  git push

  doPop;
  ;;
*)
  echo "Option invalid"
  ;;
esac
