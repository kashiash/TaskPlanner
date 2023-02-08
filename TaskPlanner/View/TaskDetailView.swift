//
//  TaskDetailView.swift
//  TaskPlanner
//
//  Created by Jacek Kosiński G on 06/02/2023.
//

import SwiftUI

struct TaskDetailView: View {
    var task: Task
    var body: some View {
        Text(task.taskDescription)
    }
}

struct TaskDetailView_Previews: PreviewProvider {
    static var previews: some View {
        TaskDetailView(task: Task.example)
    }
}
