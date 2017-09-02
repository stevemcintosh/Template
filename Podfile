target 'Template' do
    platform :ios, '11'
    workspace 'Template'
    project 'Project Files/Template.xcodeproj'
    use_frameworks!

    pod 'ProcedureKit/All'
    pod 'ProcedureKit/Mobile'
    
    # This subspec is the iOS only UIKit related stuff
    pod 'Alamofire'
    #pod 'KeychainAccess'
    pod 'SwiftyBeaver'

    target 'TemplateTests' do
        inherit! :search_paths
    end

    #target 'SmartScanUITests' do
        #inherit! :search_paths
    #end
end
