NAMESPACE=default
POD=$(kubectl get pod -l io.kompose.service=gitlab -o jsonpath="{.items[0].metadata.name}")

GITLAB_TOKEN=$(kubectl exec -it $POD -n $NAMESPACE -- gitlab-rails runner "
    user = User.find_by(username: 'root');
    token = user.personal_access_tokens.create!(name: 'backstage', scopes: ['api', 'read_repository', 'write_repository', 'read_registry', 'write_registry'], expires_at: 1.year.from_now);
    token.save!;
    puts token.token;
")