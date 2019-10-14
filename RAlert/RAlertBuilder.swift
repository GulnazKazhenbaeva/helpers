import UIKit
import SnapKit

struct RAlert {
    var title: String?
    var message: String?
    var icon: UIImage?
    var okTitle: String?
    var cancelTitle: String?
    var onNextAction: (()->())?
    var onCancelAction: (()->())?
    var customView: UIView?
//    var messageAlignment: NSTextAlignment?
    
    class Builder {
        var title: String?
        var message: String?
        var icon: UIImage?
        var okTitle: String?
        var cancelTitle: String?
        var onNextAction: (()->())?
        var onCancelAction: (()->())?
        var customView: UIView?
        var messageAlignment: NSTextAlignment?
        
        func set(title: String?) -> Builder {
            self.title = title
            return self
        }
        func set(message: String?) -> Builder {
            self.message = message
            return self
        }
        func set(icon: UIImage?) -> Builder {
            self.icon = icon
            return self
        }
        func set(okTitle: String?) -> Builder {
            self.okTitle = okTitle
            return self
        }
        func set(cancelTitle: String?) -> Builder {
            self.cancelTitle = cancelTitle
            return self
        }
        func set(onNextAction: (()->())?) -> Builder {
            self.onNextAction = onNextAction
            return self
        }
        func set(onCancelAction: (()->())?) -> Builder {
            self.onCancelAction = onCancelAction
            return self
        }
        func set(customView: UIView) -> Builder {
            self.customView = customView
            return self.set(title: nil).set(message: nil).set(icon: nil)
        }
        
//        func set(messageAlignment: NSTextAlignment) -> Builder {
//            self.messageAlignment = messageAlignment
//            return self
//        }
//
        func build() -> RAlertView {
            let model = RAlert.init(title: title,
                                   message: message,
                                   icon: icon,
                                   okTitle: okTitle,
                                   cancelTitle: cancelTitle,
                                   onNextAction: onNextAction,
                                   onCancelAction: onCancelAction,
                                   customView: customView)
            return RAlertView.init(alert: model)
        }
    }
    
}



class RAlertView: UIView, Modal {
    var onNext: (() -> ())?
    
    var onCancel: (() -> ())?

    
    var backgroundView: UIView = {
        let view = UIView.init(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
        view.backgroundColor = UIColor.black
        view.alpha = 0.6
        return view
    }()
    
    var dialogView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 4
        view.clipsToBounds = true
        view.backgroundColor = UIColor.white
        return view
    }()
    
    fileprivate lazy var iconView = UIImageView()
    fileprivate lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.textAlignment = .center
        label.font = App.Font.bold(size: .big)
        return label
    }()
    
    fileprivate lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 6
        label.textAlignment = .center
        label.font = App.Font.regular()
        return label
    }()
    
    fileprivate lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("Cancel", color: .blue)
        button.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        return button
    }()
    
    fileprivate lazy var okButton: UIButton = {
        let button = UIButton()
        button.setTitle("OK", color: .blue)
        button.addTarget(self, action: #selector(goNext), for: .touchUpInside)
        return button
    }()
    
    
    private var model: RAlert!
    init(alert: RAlert) {
        super.init(frame: .zero)
        self.model = alert
        self.onCancel = alert.onCancelAction
        self.onNext = alert.onNextAction
        
        if model.customView != nil {
            setupForCustomView()
        } else {
            setup()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupForCustomView() {
        
    }
    
    private func setup() {
        
        var lastView: UIView?
        
        dialogView.corneredView()
        addSubview(backgroundView)
        addSubview(dialogView)
        
        dialogView.snp.makeConstraints { m in
            m.left.equalTo(20)
            m.right.equalTo(-20)
            m.centerY.equalToSuperview()
        }
        
        
        if model.icon != nil {
            iconView.image = model.icon
            dialogView.addSubview(iconView)
            iconView.snp.makeConstraints { m in
                m.top.equalTo(20)
                m.width.height.equalTo(50)
                m.centerX.equalToSuperview()
            }
            lastView = iconView
        }
        
        if model.title != nil {
            titleLabel.text = model.title
            dialogView.addSubview(titleLabel)
            titleLabel.snp.makeConstraints { m in
                if lastView == nil {
                    m.top.equalTo(20)
                } else {
                    m.top.equalTo(lastView!.snp.bottom).offset(12)
                }
                m.left.equalTo(20)
                m.right.equalTo(-20)
            }
            lastView = titleLabel
        }
        
        if model.message != nil {
            messageLabel.text = model.message
            dialogView.addSubview(messageLabel)
            messageLabel.snp.makeConstraints { m in
                if lastView == nil {
                    m.top.equalTo(20)
                } else {
                    m.top.equalTo(lastView!.snp.bottom).offset(12)
                }
                m.left.equalTo(20)
                m.right.equalTo(-20)
            }
            lastView = messageLabel
        }
        
        if model.okTitle != nil {
            okButton.setTitle(model.okTitle!.uppercased(), color: .blue)
        }
        dialogView.addSubview(okButton)
        okButton.snp.makeConstraints { m in
            if lastView == nil {
                m.top.equalTo(20)
            } else {
                m.top.equalTo(lastView!.snp.bottom).offset(20)
            }
            m.right.equalTo(-12)
            m.bottom.equalTo(-20)
            m.height.equalTo(40)
            
            if model.cancelTitle == nil {
                m.left.equalTo(12)
            }
        }
        if model.cancelTitle != nil {
            dialogView.addSubview(cancelButton)
            cancelButton.setTitle(model.cancelTitle!.uppercased(), color: .blue)
            cancelButton.snp.makeConstraints { m in
                m.top.equalTo(okButton)
                m.left.equalTo(12)
                m.width.height.equalTo(okButton)
                m.right.equalTo(okButton.snp.left).offset(-12)
            }
        }
        
       
        
    }
    
    
    @objc fileprivate func goNext() {
        dismiss(animated: true, fromOkButton: true)
    }
    
    @objc fileprivate func cancel() {
        dismiss(animated: true, fromOkButton: false)
    }
}


protocol Modal {
    func show(in view: UIView, animated:Bool)
    func dismiss(animated:Bool, fromOkButton: Bool)
    var backgroundView:UIView {get}
    var dialogView:UIView {get set}
    var onNext: (()->())? {get}
    var onCancel: (()->())? {get}
}

extension Modal where Self:UIView{
    func show(in view: UIView, animated:Bool = true){
        self.backgroundView.alpha = 0
        view.addSubview(self)
        snp.makeConstraints { m in
            m.edges.equalToSuperview()
        }
        
        if animated {
            UIView.animate(withDuration: 0.33, animations: {
                self.backgroundView.alpha = 0.66
            })
            dialogView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {() -> Void in
                self.dialogView.transform = CGAffineTransform.identity
            }, completion: {(finished: Bool) -> Void in
          
            })
        }else{
            self.backgroundView.alpha = 0.66
            self.dialogView.center  = view.center
        }
    }
    
    func dismiss(animated:Bool, fromOkButton: Bool = true){
        if animated {
            UIView.animate(withDuration: 0.33, animations: {
                self.backgroundView.alpha = 0
            }, completion: nil)
            self.dialogView.transform = CGAffineTransform.identity
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {() -> Void in
                self.dialogView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
            }, completion: {(finished: Bool) -> Void in
                if fromOkButton {
                    if self.onNext != nil {
                        self.onNext!()
                    }
                } else {
                    if self.onCancel != nil {
                        self.onCancel!()
                    }
                }
                self.removeFromSuperview()
            })
        }else{
            self.removeFromSuperview()
        }
        
    }
}
