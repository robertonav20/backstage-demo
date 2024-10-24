import jenkins.model.*
import com.cloudbees.hudson.plugins.folder.*

// Get Jenkins instance
def jenkinsInstance = Jenkins.getInstance()

// Folder name
def folderName = System.getenv("JENKINS_FOLDER") ?: "backstage-demo"

// Check if the folder already exists
if (jenkinsInstance.getItem(folderName) == null) {
    // Create a new folder
    def folder = new Folder(jenkinsInstance, folderName)

    // Add the folder to Jenkins
    jenkinsInstance.add(folder, folderName)

    // Save the Jenkins configuration to reflect the changes
    jenkinsInstance.save()

    println "Folder '${folderName}' created."
} else {
    println "Folder '${folderName}' already exists."
}
