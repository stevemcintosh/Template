target 'Template' do
    platform :ios, '11'
    workspace 'Template'
    project 'Project Files/Template.xcodeproj'
    use_frameworks!

    pod 'ProcedureKit/All', :git => 'https://github.com/ProcedureKit/ProcedureKit.git', :branch => 'development'
    pod 'ProcedureKit/Mobile', :git => 'https://github.com/ProcedureKit/ProcedureKit.git', :branch => 'development'
    
    pod 'Alamofire'
    pod 'DeallocationChecker'
    #pod 'KeychainAccess'
    pod 'FTLinearActivityIndicator'
    pod 'SwiftyBeaver'

    target 'TemplateTests' do
        inherit! :search_paths
    end

    target 'TemplateUITests' do
        #inherit! :search_paths
    end
end
