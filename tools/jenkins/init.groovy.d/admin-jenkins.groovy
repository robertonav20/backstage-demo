import jenkins.model.*
import hudson.security.*

def instance = Jenkins.getInstance()

// Define the default admin username and password
def adminUsername = System.getenv("JENKINS_ADMIN_USER") ?: "admin"
def adminPassword = System.getenv("JENKINS_ADMIN_PASSWORD") ?: "admin"

// Create a security realm (auth system)
def hudsonRealm = new HudsonPrivateSecurityRealm(false)
hudsonRealm.createAccount(adminUsername, adminPassword)
instance.setSecurityRealm(hudsonRealm)

// Set up authorization strategy (full access for admin)
def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
strategy.setAllowAnonymousRead(false)
instance.setAuthorizationStrategy(strategy)

instance.save()

println "User created successfully '${adminUsername}' '${adminPassword}'"
