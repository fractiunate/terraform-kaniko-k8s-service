cd ../../

if [ -d .git ]; then
  echo .git;
else
#   git rev-parse --git-dir 2> /dev/null;
  git init
fi;


result=$(git log -p --all -S "initial commit")
if [ -z "$result" ]
then
    echo "# terraform-kaniko-k8s-service" > README.md
    git add .
    git commit -m "initial commit"
    git branch -M ${DEFAULT_BRANCH}
else
    git add .
    git commit -m "\"Terraform Apply\" commit"
    git branch -M ${DEFAULT_BRANCH}
fi

if ! OUTPUT=$(git remote show origin | grep ${REPO_SSH_URL})
then
git remote add origin ${REPO_SSH_URL}
git push -u origin ${DEFAULT_BRANCH}
else
git push
fi
