//
//  UIImage+Extension.swift
//  AutomaticPlayingVideoBanner
//
//  Created by qara_macbookpro on 2022/03/18.
//

import Foundation
import AVKit

extension AVPlayer {
  var isPlaying:Bool {
    get {
      return (self.rate != 0 && self.error == nil)
    }
  }
}
