# 1. Set Git Username/Email Globally (applies to all repos)

If you're now working full-time on client projects and want all future commits to use the official identity:
git config --global user.name "Your Official Name"
git config --global user.email "you@clientcompany.com"

Verify:
git config --global --list

# 2. Set Git Username/Email Per Repository (only for client repo)

If you're still working on personal projects too, and want to keep using personal Gmail for GitHub, but use official email only for Azure DevOps, then do this inside your local Azure repo:

cd /path/to/azure-repo
git config user.name "Your Official Name"
git config user.email "you@clientcompany.com"

Verify for current repo:
git config --list

Look for:
user.name=Your Official Name
user.email=you@clientcompany.com

# 3. Rewrite Past Commits (if needed)
If you've already committed using your personal email in this repo and want to rewrite history, you can use:

git rebase -i HEAD~N
# N = number of commits to change or for all history
git filter-branch --commit-filter '
    if [ "$GIT_COMMITTER_EMAIL" = "your@gmail.com" ];
    then
        GIT_COMMITTER_NAME="Your Official Name";
        GIT_COMMITTER_EMAIL="you@clientcompany.com";
        GIT_AUTHOR_NAME="Your Official Name";
        GIT_AUTHOR_EMAIL="you@clientcompany.com";
        git commit-tree "$@";
    else
        git commit-tree "$@";
    fi' HEAD

