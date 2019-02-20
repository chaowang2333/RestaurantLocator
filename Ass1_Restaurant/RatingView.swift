//
//  RatingView.swift
//  Ass1_Restaurant
//
//  Created by crow on 5/9/17.
//  Copyright © 2017 ChaoWang27548848. All rights reserved.
//

import UIKit

class RatingView: UIView {

    // rating
    var rating: CGFloat = 0
    var ratingMax: CGFloat = 5
    
    // total star
    var numStars: Int = 5
    
    // set default image: star
    var imageLight: UIImage = UIImage(named: "star_full")!
    var imageDark: UIImage = UIImage(named: "star_none")!
    
    var foregroundRatingView: UIView!
    var backgroundRatingView: UIView!
    var isDrew = false
    var allowEdit = false
    
    
    // set rating and change display
    func setRating(rating: CGFloat) {
        self.rating = rating
        if isDrew
        {
            changeRating()
        }
    }
    
    // build rating bar
    func buildView(){
        if isDrew {return}
        isDrew = true
        //create two view for background and fore ground rating image
        self.backgroundRatingView = self.createRatingView(imageDark)
        self.foregroundRatingView = self.createRatingView(imageLight)
        changeRating()
        self.addSubview(self.backgroundRatingView)
        self.addSubview(self.foregroundRatingView)
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapRateView))
        self.addGestureRecognizer(tap)
    }
    
    // layout subviews event
    override func layoutSubviews() {
        super.layoutSubviews()
        buildView()
    }
    
    // change rating
    func changeRating(){
        let realRatingScore = self.rating / self.ratingMax
        self.foregroundRatingView.frame = CGRect(x: 0, y: 0,width: self.bounds.size.width   * realRatingScore, height: self.bounds.size.height)
    }
    
    // create ratingView
    func createRatingView(_ image: UIImage) ->UIView{
        let view = UIView(frame: self.bounds)
        view.clipsToBounds = true
        view.backgroundColor = UIColor.clear
        // create rating item
        for position in 0 ..< numStars{
            let imageView = UIImageView(image: image)
            imageView.frame = CGRect(x: CGFloat(position) * self.bounds.size.width / CGFloat(numStars), y: 0, width: self.bounds.size.width / CGFloat(numStars), height: self.bounds.size.height)
            imageView.contentMode = UIViewContentMode.scaleAspectFit
            view.addSubview(imageView)
        }
        return view
    }
    
    // edit rating view
    func tapRateView(_ sender: UITapGestureRecognizer){
        if !allowEdit
        {
            return
        }
        // get rating
        self.rating = round(sender.location(in: self).x / (self.bounds.size.width / ratingMax))
        self.changeRating()
    }
}
