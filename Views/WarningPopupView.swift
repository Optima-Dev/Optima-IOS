import UIKit

class WarningPopupView: UIView {


    @IBOutlet weak var warningBarView: UIView! // الشريط الأصفر بالأعلى
    @IBOutlet weak var warningLabel: UILabel! // نص التحذير

    override func awakeFromNib() {
        super.awakeFromNib()
      //  setupUI()
    }

 /*   private func setupUI() {
        // جعل الزوايا مستديرة
        popupContainerView.layer.cornerRadius = 15
        popupContainerView.layer.masksToBounds = true

        // ضبط لون الشريط العلوي
        warningBarView.backgroundColor = UIColor.systemYellow

        // إضافة Gesture لإغلاق الـ Popup عند الضغط في أي مكان خارج المربع
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissPopup))
        tapGesture.cancelsTouchesInView = false
        self.addGestureRecognizer(tapGesture)
    }*/

    @objc func dismissPopup() {
        self.removeFromSuperview()
    }
}

