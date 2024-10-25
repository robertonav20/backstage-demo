export function buildCreateJobXml(repo: string, branch: string, gitlabCredentials: string) {
    return `
<project>
    <actions />
    <description></description>
    <keepDependencies>false</keepDependencies>
    <properties>
        <com.dabsquared.gitlabjenkins.connection.GitLabConnectionProperty plugin="gitlab-plugin@1.9.4">
            <gitLabConnection>gitlab</gitLabConnection>
            <jobCredentialId></jobCredentialId>
            <useAlternativeCredential>false</useAlternativeCredential>
        </com.dabsquared.gitlabjenkins.connection.GitLabConnectionProperty>
    </properties>
    <scm class="hudson.plugins.git.GitSCM" plugin="git@5.6.0">
        <configVersion>2</configVersion>
        <userRemoteConfigs>
            <hudson.plugins.git.UserRemoteConfig>
                <url>${repo}</url>
                <credentialsId>${gitlabCredentials}</credentialsId>
            </hudson.plugins.git.UserRemoteConfig>
        </userRemoteConfigs>
        <branches>
            <hudson.plugins.git.BranchSpec>
                <name>${branch}</name>
            </hudson.plugins.git.BranchSpec>
        </branches>
        <doGenerateSubmoduleConfigurations>false</doGenerateSubmoduleConfigurations>
        <submoduleCfg class="empty-list" />
        <extensions />
    </scm>
    <canRoam>true</canRoam>
    <disabled>false</disabled>
    <blockBuildWhenDownstreamBuilding>false</blockBuildWhenDownstreamBuilding>
    <blockBuildWhenUpstreamBuilding>false</blockBuildWhenUpstreamBuilding>
    <triggers />
    <concurrentBuild>false</concurrentBuild>
    <builders />
    <publishers />
    <buildWrappers />
</project>
`;
}

export function buildCreatePipelineXml(repo: string, branch: string, gitlabCredentials: string) {
    return `
<flow-definition plugin="workflow-job@1447.v559b_c710cd2e">
    <actions/>
    <description></description>
    <keepDependencies>false</keepDependencies>
    <properties>
        <com.dabsquared.gitlabjenkins.connection.GitLabConnectionProperty plugin="gitlab-plugin@1.9.4">
            <gitLabConnection>gitlab</gitLabConnection>
            <jobCredentialId></jobCredentialId>
            <useAlternativeCredential>false</useAlternativeCredential>
        </com.dabsquared.gitlabjenkins.connection.GitLabConnectionProperty>
    </properties>
    <definition class="org.jenkinsci.plugins.workflow.cps.CpsScmFlowDefinition" plugin="workflow-cps@3975.v567e2a_1ffa_22">
        <scm class="hudson.plugins.git.GitSCM" plugin="git@5.6.0">
            <configVersion>2</configVersion>
            <userRemoteConfigs>
                <hudson.plugins.git.UserRemoteConfig>
                    <url>${repo}</url>
                    <credentialsId>${gitlabCredentials}</credentialsId>
                </hudson.plugins.git.UserRemoteConfig>
            </userRemoteConfigs>
            <branches>
                <hudson.plugins.git.BranchSpec>
                <name>${branch}</name>
                </hudson.plugins.git.BranchSpec>
            </branches>
            <doGenerateSubmoduleConfigurations>false</doGenerateSubmoduleConfigurations>
            <submoduleCfg class="empty-list"/>
            <extensions/>
            </scm>
        <scriptPath>Jenkinsfile</scriptPath>
        <lightweight>true</lightweight>
    </definition>
    <triggers/>
    <disabled>false</disabled>
</flow-definition>
`;
}