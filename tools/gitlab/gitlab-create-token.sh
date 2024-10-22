CONTAINER=gitlab

GITLAB_TOKEN=$(docker-compose exec $CONTAINER gitlab-rails runner "
    user = User.find_by(username: 'root');
    token = user.personal_access_tokens.create(name: 'backstage', scopes: ['api', 'read_repository', 'write_repository', 'read_registry', 'write_registry', 'read_user', 'k8s_proxy', 'create_runner', 'manage_runner', 'admin_mode'], expires_at: 1.year.from_now);
    token.save!
    puts token.token;
")


GITLAB_OAUTH_APP=$(docker-compose exec $CONTAINER gitlab-rails runner "
    application = Doorkeeper::Application.create(name: 'backstage', redirect_uri: 'http://localhost:7007/api/auth/gitlab/handler/frame', scopes: 'api read_user', confidential: true, trusted: true);
    application.save!
    puts application.uid;
    puts application.secret;
")