import ProjectDescription

extension Project {
    public static let deploymentTarget: DeploymentTarget = .iOS(targetVersion: "15.0", devices: .iphone)
}
