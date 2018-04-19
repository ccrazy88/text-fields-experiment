import UIKit

fileprivate let font = UIFont.systemFont(ofSize: 16)
fileprivate let inputID = "InputCell"
fileprivate let textID = "TextCell"

final class ViewController:
  UIViewController,
  UICollectionViewDataSource,
  UICollectionViewDelegate,
  UICollectionViewDelegateFlowLayout,
  UITextViewDelegate
{
  let collectionView = UICollectionView(
    frame: .zero,
    collectionViewLayout: UICollectionViewFlowLayout()
  )

  override func viewDidLoad() {
    super.viewDidLoad()
    view.addSubview(collectionView)
    collectionView.backgroundColor = .white
    collectionView.register(InputCell.self, forCellWithReuseIdentifier: inputID)
    collectionView.register(TextCell.self, forCellWithReuseIdentifier: textID)
    collectionView.dataSource = self
    collectionView.delegate = self
  }

  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    collectionView.frame = view.bounds
  }

  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }

  func collectionView(
    _ collectionView: UICollectionView,
    numberOfItemsInSection section: Int
  ) -> Int {
    return 3
  }

  func collectionView(
    _ collectionView: UICollectionView,
    cellForItemAt indexPath: IndexPath
  ) -> UICollectionViewCell {
    if indexPath.item == 1 {
      // Input cell
      guard let cell = collectionView.dequeueReusableCell(
        withReuseIdentifier: inputID, for: indexPath
      ) as? InputCell else {
        fatalError()
      }
      cell.input.delegate = self
      return cell
    } else {
      // Text cells
      return collectionView.dequeueReusableCell(withReuseIdentifier: textID, for: indexPath)
    }
  }

  func collectionView(
    _ collectionView: UICollectionView,
    layout collectionViewLayout: UICollectionViewLayout,
    sizeForItemAt indexPath: IndexPath
  ) -> CGSize {
    let width = collectionView.bounds.width
    let height: CGFloat
    if indexPath.item == 1 {
      // Input cell
      let text: String
      if let cell = collectionView.cellForItem(at: indexPath) as? InputCell {
        text = cell.input.text
      } else {
        text = ""
      }
      height = InputCell.height(for: text, width: width)
    } else {
      // Text cells
      height = TextCell.height(for: width)
    }
    return CGSize(width: width, height: height)
  }

  func textViewDidChange(_ textView: UITextView) {
    let desiredHeight = InputCell.height(for: textView.text, width: textView.bounds.width)
    if desiredHeight != textView.bounds.height {
      let context = UICollectionViewFlowLayoutInvalidationContext()
      // Invalidate the text field and everything after it. We can also invalidate the entire layout
      // if this is too complicated.
      context.invalidateItems(at: [IndexPath(item: 1, section: 0), IndexPath(item: 2, section: 0)])
      collectionView.collectionViewLayout.invalidateLayout(with: context)
    }
  }
}

final class InputCell: UICollectionViewCell {
  let input: UITextView = {
    let textView = UITextView()
    textView.isScrollEnabled = false
    textView.textContainerInset = .zero
    textView.textContainer.lineFragmentPadding = 0
    textView.font = font
    return textView
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)
    contentView.addSubview(input)
    layer.borderColor = UIColor.black.cgColor
    layer.borderWidth = 1
  }

  required init?(coder: NSCoder) {
    fatalError()
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    input.frame = contentView.bounds
  }

  static func height(for text: String, width: CGFloat) -> CGFloat {
    return text.height(font: font, width: width)
  }
}

final class TextCell: UICollectionViewCell {
  static let text = "this is a text cell"

  let label: UILabel = {
    let label = UILabel()
    label.font = font
    label.text = TextCell.text;
    return label
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)
    contentView.addSubview(label)
    layer.borderColor = UIColor.black.cgColor
    layer.borderWidth = 1
  }

  required init?(coder: NSCoder) {
    fatalError()
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    label.frame = contentView.bounds
  }

  static func height(for width: CGFloat) -> CGFloat {
    return text.height(font: font, width: width)
  }
}

extension String {
  func height(font: UIFont, width: CGFloat) -> CGFloat {
    if isEmpty {
      return ceil(font.lineHeight)
    }
    let maxSize = CGSize(width: width, height: .greatestFiniteMagnitude)
    let size = (self as NSString).boundingRect(
      with: maxSize,
      options: [.usesLineFragmentOrigin, .usesFontLeading],
      attributes: [.font: font],
      context: nil
    )
    return ceil(size.height)
  }
}
