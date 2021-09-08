#!/bin/sh

git add -A
echo 'git add, done.'
 
read -p "Your commit info: " info
git commit -m $info
echo 'git commit, done.'

git branch -M main

flag=1
while $flag==1;do
    git push origin main & { sleep 10; kill $! & $flag=0 }
    if [$flag==0]
    then
        break 2
    else 
    	$flag=1
    fi
done;

echo 'git push, done.'

npm run build
echo 'build, done.'

cd public
pwd

git init

git add -A
echo 'git add, done.'

git commit -m ${info}
echo 'git commit, done.'

git remote add origin https://github.com/Radeity/blog.git
git remote set-url origin https://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@github.com/Radeity/blog.git

flag = 1
while $flag==1;do
    git push -f origin master:gh-pages  {sleep 10; kill $! & $flag=0 }
    if [$flag==0]
    then
        break 2
    else 
    	$flag=1
    fi
done;
echo 'update your blog, done,  exit!'




