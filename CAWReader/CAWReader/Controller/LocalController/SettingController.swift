//
//  SettingController.swift
//  CAWReader
//
//  Created by wbuntu on 5/15/16.
//  Copyright © 2016 wbuntu. All rights reserved.
//

import UIKit

class SettingController: BaseController, UITableViewDelegate, UITableViewDataSource, SettingDataCellDelegate {
    var tableView:UITableView!
    let previewCellHeight:CGFloat = screenHeight-64-SettingDataCell.cellHeight*3
    static let contentStr:String = "在这个村落，人们会把迎风摇曳的饱满麦穗形容成狼在奔跑.\n因为麦穗迎风摇曳的姿态，就像在麦田里奔跑的狼。\n人们还会说被强风吹倒的麦穗是遭狼践踏，收成不好时会说是被狼给吃了。\n这种比喻虽然贴切，但其中也包含了负面的意味，显得美中不足。\n不过，如今这些比喻只是带点玩笑性质的说法，几乎不再有人会像从前一样，带着亲密感与恐惧感来使用这些话语。\n从阵阵摇摆的麦穗缝中仰望的秋天天空，即使过了好几百年也不曾改变，但是底下的人事物全变了样。\n年复一年，勤奋种麦的村民们再怎么长寿，也不过活到七十岁。\n要是人事物好几百年都没有改变，反而不见得好。\n只是，不禁让人觉得，或许没必要再为了情义而守护以往的承诺。\n这里的村民已不再需要咱了。\n耸立在东方的高山，使得村落天空的云朵多半飘向北方。\n想起位在云朵飘去那一头的北方故乡，便忍不住叹了口气。\n把视线从天空拉回麦田，引以为傲的尾巴就在面前摇摆。\n闲来无事只好专心梳理尾巴的毛。\n秋天的天空高而清澈。\n今年又到了收割的时期。\n成群无数的狼在麦田里奔跑。"
    var attStr:NSAttributedString!
    weak var previewLayer:CALayer!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView = UITableView(frame: CGRectMake(0, 0, self.view.width, self.view.height), style: .Grouped)
        tableView.backgroundColor = commonBackgroundColor
        tableView.delegate = self
        tableView.dataSource = self
        tableView.scrollEnabled = false
        tableView.registerClass(SettingLineSpacingCell.self, forCellReuseIdentifier: SettingLineSpacingCell.cellIdentifeir)
        tableView.registerClass(SettingParagraphSpacingCell.self, forCellReuseIdentifier: SettingParagraphSpacingCell.cellIdentifeir)
        tableView.registerClass(SettingFirstHeadindentCell.self, forCellReuseIdentifier: SettingFirstHeadindentCell.cellIdentifeir)
        tableView.registerClass(SettingPreviewCell.self, forCellReuseIdentifier: SettingPreviewCell.cellIdentifeir)
        self.view.addSubview(tableView)
        // Do any additional setup after loading the view.
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.row == 0{
            return previewCellHeight
        }else{
            return SettingDataCell.cellHeight
        }
    }
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0001
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0001
    }
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier(SettingLineSpacingCell.cellIdentifeir, forIndexPath: indexPath) as! SettingLineSpacingCell
            cell.delegate = self
            return cell
        case 2:
            let cell = tableView.dequeueReusableCellWithIdentifier(SettingParagraphSpacingCell.cellIdentifeir, forIndexPath: indexPath) as! SettingParagraphSpacingCell
            cell.delegate = self
            return cell
        case 3:
            let cell = tableView.dequeueReusableCellWithIdentifier(SettingFirstHeadindentCell.cellIdentifeir, forIndexPath: indexPath) as! SettingFirstHeadindentCell
            cell.delegate = self
            return cell
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier(SettingPreviewCell.cellIdentifeir, forIndexPath: indexPath) as! SettingPreviewCell
            previewLayer = cell.contentLayer
            didChangeStyle()
            return cell
        }
    }
    func didChangeStyle() {
        
        let pa = NSMutableParagraphStyle()
        let font = UIFont.systemFontOfSize(CGFloat(WWMemory.shared.fontSize!))
        pa.firstLineHeadIndent = CGFloat(WWMemory.shared.firstHeadIndent!)*font.pointSize
        pa.paragraphSpacing = CGFloat(WWMemory.shared.paragraphSpacing!)
        pa.lineSpacing = CGFloat(WWMemory.shared.lineSpacing!)
        
        attStr = NSAttributedString(string: SettingController.contentStr, attributes: [NSFontAttributeName:font,NSParagraphStyleAttributeName:pa,NSForegroundColorAttributeName:(WWMemory.shared.theme?.colorComponent().textColor)!])
        
        let rect = previewLayer.bounds
        let frameStter = CTFramesetterCreateWithAttributedString(self.attStr)
        var transform = CGAffineTransformIdentity
        let path = CGPathCreateWithRect(CGRectMake(0, 0, rect.width, rect.height), &transform)
        let frame = CTFramesetterCreateFrame(frameStter, CFRangeMake(0, 0), path, nil)
        
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        let ctx = UIGraphicsGetCurrentContext()!
        CGContextTranslateCTM(ctx, 0, rect.height)
        CGContextScaleCTM(ctx, 1, -1)
        CTFrameDraw(frame, ctx)
        previewLayer.contents = CGBitmapContextCreateImage(ctx)
        UIGraphicsEndImageContext()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
