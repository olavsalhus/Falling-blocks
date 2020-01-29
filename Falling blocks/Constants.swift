//
//  Constants.swift
//  Falling blocks
//
//  Created by Olav Salhus on 29/01/2020.
//  Copyright © 2020 Olav Salhus. All rights reserved.
//

import Foundation
import UIKit


let timeIntervals = [
    43.0 / 60.0,
    38.0 / 60.0,
    33.0 / 60.0,
    28.0 / 60.0,
    23.0 / 60.0,
    18.0 / 60.0,
    13.0 / 60.0,
    8.0 / 60.0,
    6.0 / 60.0,
    5.0 / 60.0,
    4.0 / 60.0,
    3.0 / 60.0,
    2.0 / 60.0,
    1.0 / 60.0
]

let shapes = [
    [[1, 1],
     [1, 1]],
    
    [[0, 0, 0, 0],
     [1, 1, 1, 1],
     [0, 0, 0, 0]],
    
    [[0, 0, 1],
     [1, 1, 1],
     [0, 0, 0]],
    
    [[0, 0, 0],
     [1, 1, 1],
     [0, 0, 1]],
    
    [[0, 1, 0],
     [1, 1, 1],
     [0, 0, 0]],
    
    [[1, 1, 0],
     [0, 1, 1]],
    
    [[0, 1, 1],
     [1, 1, 0]]
]




    
let tetrominos = """
--------
        
[][][][]
        
--------
    []
[][][]
        
--------
        
[][][]
    []
--------
[][]
  [][]
--------
  [][]
[][]
--------
[][]
[][]
--------
  []
[][][]
        
--------
"""
    
    // Pentominos mode also uses smaller bricks to make it easier
    let pentominos =
"""
----------|----------
[]        |[][]
----------|----------
          |
  [][]    |[][][]
  []      |
----------|----------
          |  []
          |[][][]
[][][][][]|  []
          |----------
          |[][][]
----------|  []
          |  []
[][][]    |----------
[]  []    |[]
----------|[][]
[][][]    |  [][]
[]        |----------
[]        |[]
----------|[][][][]
          |
[][][][]  |----------
[]        |[][]
----------|[][][]
[][]      |----------
[][][]    |[][]
----------|  [][]
  [][]    |  []
[][]      |----------
  []      |  []
----------|[][][][]
          |
[][][][]  |----------
  []      |    [][]
----------|[][][]
[][]      |----------
  [][][]  |[][]
----------|  []
  [][]    |  [][]
  []      |----------
[][]      |
----------|
"""
    
    var shapeColors : [UIColor] = [.yellow, .cyan, .orange, .blue, .purple, .red, .green]
