#!/usr/bin/env sh
git add .
echo "git add ."

git commit -m "publish post"

echo "git commit "

git push origin hexo

echo "git push origin hexo"

echo "start deploy"

hexo deploy
