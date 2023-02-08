//
//  Home.swift
//  TaskPlanner
//
//  Created by Balaji on 04/01/23.
//

import SwiftUI

struct Home: View {
    /// - View Properties
    ///
    ///
    @State private var weekDays: [WeekDay] = []
    @State private var currentDay: Date = .init()
    @State private var tasks: [Task] = sampleTasks
    @State private var addNewTask: Bool = false
    @State private var pushView: Bool = false
    
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            TimelineView()
                .padding(15)
        }
        .safeAreaInset(edge: .top,spacing: 0) {
            HeaderView()
        }
        .fullScreenCover(isPresented: $addNewTask) {
            AddTaskView { task in
                /// - Simply Add it to tasks
                tasks.append(task)
            }
        }
    }
    
    /// - Timeline View
    @ViewBuilder
    func TimelineView()->some View{
        ScrollViewReader { proxy in
            let hours = Calendar.current.hours
            let midHour = hours[hours.count / 2]
            VStack{
                ForEach(hours,id: \.self){hour in
                    TimelineViewRow(hour)
                        .id(hour)
                }
            }
            .onAppear {
                proxy.scrollTo(midHour)
            }
        }
    }
    
    /// - Timeline View Row
    @ViewBuilder
    func TimelineViewRow(_ date: Date)->some View{
        
        HStack(alignment: .top) {
            
            Text(date.toString("h a"))
                .ubuntu(14, .regular)
                .frame(width: 45,alignment: .leading)
            
            /// - Filtering Tasks
            let calendar = Calendar.current
            let filteredTasks = tasks.filter{
                if let hour = calendar.dateComponents([.hour], from: date).hour,
                   let taskHour = calendar.dateComponents([.hour], from: $0.dateAdded).hour,
                   hour == taskHour && calendar.isDate($0.dateAdded, inSameDayAs: currentDay){
                    return true
                }
                return false
            }
            
            if filteredTasks.isEmpty{
                Rectangle()
                    .stroke(.gray.opacity(0.5), style: StrokeStyle(lineWidth: 0.5, lineCap: .butt, lineJoin: .bevel, dash: [5], dashPhase: 5))
                    .frame(height: 0.5)
                    .offset(y: 10)
            }else{
                /// - Task View
                VStack(spacing: 10){
                    ForEach(filteredTasks){task in
                        Button{
                            pushView.toggle()
                        } label: {
                            TaskRow(task)
                        }
                        .navigationDestination(isPresented: $pushView){
                            TaskDetailView(task: task)
                        }
                    }
                }
            }
        }
        .hAlign(.leading)
        .padding(.vertical,15)
        
    }
    
    /// - Task Row
    @ViewBuilder
    func TaskRow(_ task: Task)->some View{
        VStack(alignment: .leading, spacing: 8) {
            Text(task.taskName.uppercased())
                .ubuntu(16, .regular)
                .foregroundColor(task.taskCategory.color)
                .lineLimit(1)
            
            if task.taskDescription != ""{
                Text(task.taskDescription)
                    .ubuntu(14, .light)
                    .foregroundColor(task.taskCategory.color.opacity(0.8))
                    .lineLimit(6)
            }
        }
        .hAlign(.leading)
        .padding(12)
        .background {
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(task.taskCategory.color)
                    .frame(width: 4)
                
                Rectangle()
                    .fill(task.taskCategory.color.opacity(0.25))
            }
        }
    }
    
    /// - Header View
    @ViewBuilder
    func HeaderView()->some View{
        VStack{
            HStack{
                Button {
                    currentDay = .now
                    weekDays = Calendar.current.getDays(date: currentDay)
                } label: {
                    HStack(spacing: 10){
                        
                        Text("Today")
                            .ubuntu(15, .regular)
                    }
                    .padding(.vertical,10)
                    .padding(.horizontal,15)
                    .background {
                        Capsule()
                            .fill(Color("Blue").gradient)
                    }
                    .foregroundColor(.white)
                }
                .hAlign(.leading)
                
                Button {
                    addNewTask.toggle()
                } label: {
                    HStack(spacing: 10){
                        
                        Text("Add Task")
                            .ubuntu(15, .regular)
                    }
                    .padding(.vertical,10)
                    .padding(.horizontal,15)
                    .background {
                        Capsule()
                            .fill(Color("Blue").gradient)
                    }
                    .foregroundColor(.white)
                }
                .hAlign(.trailing)
            }
            HStack{
                Button{
                    var dateComponent = DateComponents()
                    dateComponent.day = -7
                    currentDay =   Calendar.current.date(byAdding: dateComponent, to: currentDay)!
                    weekDays = Calendar.current.getDays(date: currentDay)
                } label:{
                    Image(systemName: "arrowtriangle.left.circle")
                        .font(.system(size: 50))
                        .foregroundStyle(.orange.gradient)
                }
                .hAlign(.leading)
                .font(.headline)
                .padding(.top,15)
                
                /// - Today Date in String
                Text(currentDay,format: .dateTime.day().month().year())
                    .ubuntu(16, .medium)
                    .hAlign(.leading)
                    .padding(.top,15)
                
                Button{
                    var dateComponent = DateComponents()
                    dateComponent.day = 7
                    currentDay =   Calendar.current.date(byAdding: dateComponent, to: currentDay)!
                    weekDays = Calendar.current.getDays(date: currentDay)
                } label:{
                    Image(systemName: "arrowtriangle.right.circle")
                        .font(.system(size: 50))
                        .foregroundStyle(.green.gradient)
                }
                .hAlign(.trailing)
                
                .padding(.top,15)
                
            }
            
            /// - Current Week Row
            WeekRow()
            
        }
        .padding(15)
        .background {
            VStack(spacing: 0) {
                Color.white
                
                /// - Gradient Opacity Background
                Rectangle()
                    .fill(.linearGradient(colors: [
                        .white,
                        .clear
                    ], startPoint: .top, endPoint: .bottom))
                    .frame(height: 20)
            }
            .ignoresSafeArea()
        }
    }
    
    /// - Week Row
    @ViewBuilder
    func WeekRow()->some View{
        HStack(spacing: 0){
            ForEach(weekDays){weekDay in
                let status = Calendar.current.isDate(weekDay.date, inSameDayAs: currentDay)
                VStack(spacing: 6){
                    Text(weekDay.string.prefix(3))
                        .ubuntu(12, .medium)
                    Text(weekDay.date.toString("dd"))
                        .ubuntu(16, status ? .medium : .regular)
                }
                .overlay(alignment: .bottom, content: {
                    if weekDay.isToday{
                        Circle()
                            .frame(width: 6, height: 6)
                            .offset(y: 12)
                    }
                })
                .foregroundColor(status ? Color("Blue") : .gray)
                .hAlign(.center)
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.3)){
                        currentDay = weekDay.date
                    }
                }
                .gesture(
                    DragGesture()
                    //                        .onChanged { value in
                    //                            withAnimation {
                    //                                var dateComponent = DateComponents()
                    //                                if value.predictedEndTranslation.width > 300 {
                    //                                    dateComponent.day = -1
                    //                                } else {
                    //                                    dateComponent.day = 1
                    //                                }
                    //                                currentDay =   Calendar.current.date(byAdding: dateComponent, to: currentDay)!
                    //                                weekDays = Calendar.current.getDays(date: currentDay)
                    //                            }
                    //
                    //                        }
                        .onEnded { value in
                            withAnimation {
                                var dateComponent = DateComponents()
                                if value.predictedEndTranslation.width > 0 {
                                    dateComponent.day = -7
                                    
                                } else {
                                    dateComponent.day = 7
                                }
                                currentDay =   Calendar.current.date(byAdding: dateComponent, to: currentDay)!
                                weekDays = Calendar.current.getDays(date: currentDay)
                            }
                        }
                )
            }
        }
        .onAppear{
            weekDays = Calendar.current.getDays(date: .now)
        }
        .padding(.vertical,10)
        .padding(.horizontal,-15)
    }
}

struct Home_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

// MARK: View Extensions
extension View{
    func hAlign(_ alignment: Alignment)->some View{
        self
            .frame(maxWidth: .infinity,alignment: alignment)
    }
    
    func vAlign(_ alignment: Alignment)->some View{
        self
            .frame(maxHeight: .infinity,alignment: alignment)
    }
}

// MARK: Date Extension
extension Date{
    func toString(_ format: String)->String{
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}

// MARK: Calander Extension
extension Calendar{
    /// - Return 24 Hours in a day
    var hours: [Date]{
        let startOfDay = self.startOfDay(for: Date())
        var hours: [Date] = []
        for index in 0..<24{
            if let date = self.date(byAdding: .hour, value: index, to: startOfDay){
                hours.append(date)
            }
        }
        
        return hours
    }
    
    func getDays(date: Date)->[WeekDay]{
        guard let firstWeekDay = self.dateInterval(of: .weekOfMonth, for: date)?.start else{return []}
        var week: [WeekDay] = []
        for index in 0..<7{
            if let day = self.date(byAdding: .day, value: index, to: firstWeekDay){
                let weekDaySymbol: String = day.toString("EEEE")
                let isToday = self.isDateInToday(day)
                week.append(.init(string: weekDaySymbol, date: day,isToday: isToday))
            }
        }
        
        return week
    }
    
    /// - Returns Current Week in Array Format
    var currentWeek: [WeekDay]{
        guard let firstWeekDay = self.dateInterval(of: .weekOfMonth, for: Date())?.start else{return []}
        var week: [WeekDay] = []
        for index in 0..<7{
            if let day = self.date(byAdding: .day, value: index, to: firstWeekDay){
                let weekDaySymbol: String = day.toString("EEEE")
                let isToday = self.isDateInToday(day)
                week.append(.init(string: weekDaySymbol, date: day,isToday: isToday))
            }
        }
        
        return week
    }
    
    /// - Used to Store Data of Each Week Day
    
}
struct WeekDay: Identifiable{
    var id: UUID = .init()
    var string: String
    var date: Date
    var isToday: Bool = false
}
