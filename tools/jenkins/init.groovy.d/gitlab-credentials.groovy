import com.cloudbees.plugins.credentials.*
import com.cloudbees.plugins.credentials.domains.*
import com.cloudbees.plugins.credentials.impl.*
import jenkins.model.*
import hudson.util.Secret

def globalDomain = Domain.global()
def instance = Jenkins.getInstance()

def credentialsStore = instance.getExtensionList('com.cloudbees.plugins.credentials.SystemCredentialsProvider')[0]?.getStore()

// GitLab credentials (username and password from environment variables)
def gitlabUsername = System.getenv("GITLAB_USER") ?: "gitlab-user"
def gitlabPassword = System.getenv("GITLAB_PASSWORD") ?: "gitlab-password"

// Create a new UsernamePasswordCredentialsImpl object with the GitLab credentials
def gitlabCreds = new UsernamePasswordCredentialsImpl(
    CredentialsScope.GLOBAL,   // Scope
    "gitlab-credentials",      // Credentials ID
    "GitLab Credentials",      // Description
    gitlabUsername,            // Username
    gitlabPassword             // Password
)

// Add credentials to the global credentials store
credentialsStore.addCredentials(globalDomain, gitlabCreds)
instance.save()

println "Credentials created successfully '${gitlabUsername}' '${gitlabPassword}'"
