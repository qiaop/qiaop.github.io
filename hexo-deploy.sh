#!/usr/bin/env sh
git add . 
wait
echo "git add ." 
wait
git commit -m "publish post" 
wait
echo "git commit " 
wait
git push origin hexo 
wait
echo "git push origin hexo" 

echo "start generate" 
hexo g
echo "hexo g"
wait
echo "start deploy"
hexo deploy
wait
echo "deploy success"

