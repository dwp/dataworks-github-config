import jinja2
import os
import yaml
import glob


def main():
    files_to_ignore = [
        'github.tf',
        'main.tf',
        'terraform.tf',
        'dataworks-github-config.tf',
    ]
    file_names = [x for x in glob.glob('*.tf') if x not in files_to_ignore]
    repos = [s.replace('.tf', '') for s in file_names]
    with open('ci/repo_resources.yml.j2') as in_repo_resources_template:
        repo_resources_template = jinja2.Template(in_repo_resources_template.read())
    with open('ci/repo_resources.yml', 'w+') as repo_resources_yml:
        repo_resources_yml.write(repo_resources_template.render(repos=repos))
    print("ci/repo_resources.yml successfully created")
    with open('ci/jobs/deploy_commit_hooks.yml.j2') as in_deploy_commit_hooks_template:
        deploy_commit_hooks_template = jinja2.Template(in_deploy_commit_hooks_template.read())
    with open('ci/jobs/deploy_commit_hooks.yml', 'w+') as deploy_commit_hooks_yml:
        deploy_commit_hooks_yml.write(deploy_commit_hooks_template.render(repos=repos))
    print("ci/jobs/deploy_commit_hooks.yml successfully created")


if __name__ == "__main__":
    main()

