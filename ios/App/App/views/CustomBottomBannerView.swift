import UIKit
import MapboxNavigation


protocol CustomBottomBannerViewDelegate: AnyObject {
    func customBottomBannerDidCancel(_ banner: CustomBottomBannerView)
}

class CustomBottomBannerView : UIView {
    @IBOutlet weak var etaLabel: UILabel!
    
    weak var delegate: CustomBottomBannerViewDelegate?
    
    var eta: String? {
        get {
            return etaLabel.text
        }
        set {
            etaLabel.text = newValue
        }
    }
    
    
    private let blurEffectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .extraLight)
        let effectView = UIVisualEffectView(effect: blurEffect)
        effectView.translatesAutoresizingMaskIntoConstraints = false
        return effectView
    }()
    
    private let button: UIButton = {
        let button = UIButton()
        button.setTitle("X", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        button.backgroundColor = UIColor(red: 255/255, green: 0/255, blue: 77/255, alpha: 1)
        button.layer.cornerRadius = 20
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
        
    private func commonInit() {
        backgroundColor = UIColor.white.withAlphaComponent(0.5)

        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        layer.cornerRadius = 32
        clipsToBounds = true
        
        
        addSubview(blurEffectView)
        addSubview(button)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            blurEffectView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurEffectView.trailingAnchor.constraint(equalTo: trailingAnchor),
            blurEffectView.topAnchor.constraint(equalTo: topAnchor),
            blurEffectView.bottomAnchor.constraint(equalTo: bottomAnchor),

            button.centerXAnchor.constraint(equalTo: trailingAnchor, constant: -48),
            button.centerYAnchor.constraint(equalTo: centerYAnchor),
            button.widthAnchor.constraint(equalToConstant: 56),
            button.heightAnchor.constraint(equalToConstant: 48),
        ])
        
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
    }
    
    @objc func buttonTapped() {
        delegate?.customBottomBannerDidCancel(self)
    }

    @IBAction func onCancel(_ sender: Any) {
        delegate?.customBottomBannerDidCancel(self)
    }
}
