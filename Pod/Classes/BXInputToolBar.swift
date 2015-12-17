
import UIKit

// Build for target uimodel
//locale (None, None)
import UIKit
import BXModel
import PinAutoLayout

// -BXInputToolBar:tb
// send[r8,b4,h36]:b
// _[l0,r0,t4,b4]:tv
// assist[l8,b4,h36]:b

public class BXInputToolBar : UIToolbar{
  public let sendButton = UIButton(type:.System)
  public let textView = ExpandableTextView(frame:CGRectZero)
  
  public let assistButton = UIButton(type:.System)
  
  public struct Settings{
    public static var preferedHeight : CGFloat = 64
  }
 
  
  private var retainCycle:AnyObject?
  
  public static var sharedInputBar:BXInputToolBar{
    if let window = UIApplication.sharedApplication().keyWindow{
      for view in window.subviews{
        if let inputBar = view as? BXInputToolBar{
          return inputBar
        }
      }
    }
    return BXInputToolBar()
  }
  
  private convenience init(){
    self.init(frame:CGRect(x: 0, y: 0, width: 320, height: Settings.preferedHeight))
    retainCycle = self
  }
  
  private override init(frame: CGRect) {
    super.init(frame: frame)
    commonInit()
  }
  
  override public func awakeFromNib() {
    super.awakeFromNib()
    commonInit()
  }
  
  var allOutlets :[UIView]{
    return [sendButton,textView,assistButton]
  }
  var allUIButtonOutlets :[UIButton]{
    return [sendButton,assistButton]
  }
  var allUITextViewOutlets :[UITextView]{
    return [textView]
  }
  required public init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  func commonInit(){
//    translatesAutoresizingMaskIntoConstraints = false
    for childView in allOutlets{
      addSubview(childView)
      childView.translatesAutoresizingMaskIntoConstraints = false
    }
    installConstaints()
    setupAttrs()
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillChangeFrame:", name: UIKeyboardWillChangeFrameNotification, object: nil)
    
  }
  
  public func dismiss(){
    textView.resignFirstResponder()
    removeFromSuperview()
    retainCycle = nil
  }
  
  public func hide(){
    textView.resignFirstResponder()
    self.hidden = true
    superview?.sendSubviewToBack(self)
    
  }
  
  public func show(){
   guard let window = UIApplication.sharedApplication().keyWindow else{
      NSNotificationCenter.defaultCenter().addObserver(self, selector: "windowDidBecomeVisible:", name: UIWindowDidBecomeVisibleNotification, object: nil)
      return
    }
    showIn(window)
  }
  
  func showIn(window:UIWindow){
    if let superview = self.superview{
      if superview == window{
        self.hidden = false
        superview.bringSubviewToFront(self)
      }else{
        self.removeFromSuperview()
        self.hidden = false
        window.addSubview(self)
      }
    }else{
      self.hidden = false
      window.addSubview(self)
    }
    frame = window.bounds.divide(Settings.preferedHeight, fromEdge: CGRectEdge.MaxYEdge).slice
  }
  
  func windowDidBecomeVisible(notification:NSNotification){
    NSLog("\(__FUNCTION__) \(notification)")
    NSLog("\(__FUNCTION__) \(UIApplication.sharedApplication().windows)")
    showIn(UIApplication.sharedApplication().windows[0])
  }
  
 
  public override class func requiresConstraintBasedLayout() -> Bool{
    return true
  }
 
  public var assistButtonHeightConstraint:NSLayoutConstraint!
  public var assistButtonBottomConstraint:NSLayoutConstraint!
  public var assistButtonLeadingConstraint:NSLayoutConstraint!
  
  public var sendButtonHeightConstraint:NSLayoutConstraint!
  public var sendButtonBottomConstraint:NSLayoutConstraint!
  public var sendButtonTrailingConstraint:NSLayoutConstraint!
  
  public var textViewTopConstraint:NSLayoutConstraint!
  public var textViewBottomConstraint:NSLayoutConstraint!
  public var textViewLeadingRelativeConstraint:NSLayoutConstraint!
  public var textViewTrailingRelativeConstraint:NSLayoutConstraint!
  
  var horizontalConstraints:[NSLayoutConstraint]{
    return [assistButtonLeadingConstraint,textViewLeadingRelativeConstraint,textViewTrailingRelativeConstraint,sendButtonTrailingConstraint]
  }
  
  func installConstaints(){
    assistButtonHeightConstraint =  assistButton.pinHeight(36)
    assistButtonBottomConstraint =  assistButton.pinBottom(4)
    assistButtonLeadingConstraint = assistButton.pinLeading(8)

    
    textViewLeadingRelativeConstraint =  textView.pinLeadingToSibling(assistButton, margin: 8)
    textViewBottomConstraint =  textView.pinBottom(8)
    textViewTopConstraint =  textView.pinTop(8)
    textViewTrailingRelativeConstraint =  textView.pinTrailingToSibing(sendButton, margin: 8)
    
    sendButtonHeightConstraint =  sendButton.pinHeight(36)
    sendButtonTrailingConstraint =  sendButton.pinTrailing(8)
    sendButtonBottomConstraint = sendButton.pinBottom(4)
  }
  
  func setupAttrs(){
   textView.setContentHuggingPriority(240, forAxis: .Horizontal)
   textView.setContentHuggingPriority(240, forAxis: .Vertical)
    sendButton.setTitle("发送", forState: .Normal)
    assistButton.setTitle("附件", forState: .Normal)
    textView.setTextPlaceholder("写点什么吧")
    for button in allUIButtonOutlets{
      button.setContentCompressionResistancePriority(760, forAxis: .Horizontal)
    }
  }
  
  deinit{
    NSLog("BXInputToolbar deinit")
    NSNotificationCenter.defaultCenter().removeObserver(self)
  }
  
  // MARK: UIKeyboard Support
  func keyboardWillChangeFrame(notification:NSNotification){
    NSLog("keyboardFrameWillChange \(notification)")
    let userInfo = notification.userInfo!
    let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey]!.doubleValue
    let options = UIViewAnimationOptions.TransitionFlipFromBottom
    let keyboardEndFrame = userInfo[UIKeyboardFrameEndUserInfoKey]!.CGRectValue
    
   
    // Calculate newFrame
      var newFrame = self.frame
      NSLog("oldFrame:\(newFrame)")
      newFrame.origin.y = keyboardEndFrame.minY - newFrame.height
      newFrame.size.width = keyboardEndFrame.width
      NSLog("newFrame:\(newFrame)")
    
    UIView.animateWithDuration(duration, delay: 0, options: options, animations: { () -> Void in
      self.frame = newFrame
      }, completion: { (finished) -> Void in

    })
  }
  
  
  public override func traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    NSLog("\(__FUNCTION__) \(previousTraitCollection)")
    if let window = self.window{
      frame = window.bounds.divide(Settings.preferedHeight, fromEdge: CGRectEdge.MaxYEdge).slice
    }

  }
}

