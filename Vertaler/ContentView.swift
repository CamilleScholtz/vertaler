//
//  ContentView.swift
//  Vertaler
//
//  Created by Camille Scholtz on 20/06/2021.
//

import SwiftUI

struct ContentView: View {
	@StateObject private var translator = DeepL()
	
	@State private var progressOpacity = 0.0
	@State private var placeholerOpacity = 1.0
	
    var body: some View {
		VStack {
			HStack(alignment: .top) {
				Spacer()
				
				DropDown(selection: $translator.sourceLanguage, list: $translator.sourceLanguages)
				SwapButton(a: $translator.sourceLanguage, b: $translator.targetLanguage)
				DropDown(selection: $translator.targetLanguage, list: $translator.targetLanguages)
				
				Spacer()
			}
			
			VStack {
				ZStack(alignment: .topLeading) {
					TextEditor(text: $translator.sourceText)
						.font(.system(size: 20.0))
						.padding()
						.background(Color(.textBackgroundColor))
						.cornerRadius(13.0)
					
					Text("Type to translate.")
						.font(.system(size: 20.0))
						.padding(.leading, 4.5)
						.foregroundColor(Color(.placeholderTextColor))
						.padding(.all)
						.allowsHitTesting(false)
						.opacity(placeholerOpacity)
						.onChange(of: translator.sourceText, perform: { _ in
							withAnimation(.easeInOut(duration: 0.1)) {
								if translator.sourceText > "" {
									placeholerOpacity = 0.0
								} else {
									placeholerOpacity = 1.0
								}
							}
						})
				}
				
				Spacer(minLength: 30.0)
				
				ZStack {
					TextEditor(text: $translator.targetText)
						.font(.system(size: 20.0))
						.padding()
						.background(Color(.textBackgroundColor))
						.cornerRadius(13.0)
					
					ProgressView()
						.opacity(progressOpacity)
						.onChange(of: translator.sourceText, perform: { _ in
							withAnimation(.easeInOut(duration: 0.1)) {
								progressOpacity = 1.0
							}
						})
						.onChange(of: translator.targetText, perform: { _ in
							withAnimation(.easeInOut(duration: 0.1)) {
								progressOpacity = 0.0
							}
						})
				}
			}
			.padding(30.0)
			.padding(.top, -10.0)
		}
		.frame(minWidth: 800.0, minHeight: 450.0)
		.onChange(of: translator.sourceLanguage) { _ in
			translator.translate(text: translator.sourceText)
		}
		.onChange(of: translator.targetLanguage) { _ in
			translator.translate(text: translator.sourceText)
		}
    }
}

struct DropDown: View {
	@Binding var selection: DeepL.Language?
	@Binding var list: [DeepL.Language]
	
	@State private var expanded = false
	@State private var hovering = DeepL.Language(name: "-", language: "-")

	var body: some View {
		VStack(alignment: .leading, spacing: 10.0) {
			if !expanded {
				HStack {
					Spacer()
					Text(selection?.name.capitalized ?? "-")
					Image(systemName: expanded ? "chevron.up" : "chevron.down")
						.font(.system(size: 10.0))
					Spacer()
				}
				.padding()
				.background(Color(.windowBackgroundColor))
				.cornerRadius(13.0)
				.onTapGesture(perform: {
					withAnimation(.spring()) {
						expanded.toggle()
					}
				})
			}
			
			if expanded {
				ScrollView {
					VStack(alignment: .leading, spacing: 0.0) {
						ForEach(list) { value in
							VStack(alignment: .center) {
								Spacer()
								HStack {
									if value == selection {
										Image(systemName: "checkmark")
											.font(.system(size: 10.0))
									}
									Text(value.name.capitalized)
								}
								.padding(9.0)
						
								Divider()
							}
							.background(Color(.controlAccentColor).opacity(hovering == value ? 0.9 : 1.0))
							.onHover(perform: { _ in
								hovering = value
							})
							.onTapGesture(perform: {
								selection = value
								
								withAnimation(.spring()) {
									expanded.toggle()
								}
							})
						}
					}
				}
				.frame(maxHeight: 300.0)
			}
		}
		.frame(width: 200.00)
		.cornerRadius(13.0)
	}
}

struct SwapButton: View {
	@Binding var a: DeepL.Language?
	@Binding var b: DeepL.Language?
	
	@State private var angle = 0.0
	
	var body: some View {
		Image(systemName: "arrow.triangle.2.circlepath")
			.font(.system(size: 15.0))
			.padding()
			.background(Color.gray.opacity(0.0001))
			.rotationEffect(.degrees(angle))
			.animation(.easeInOut)
			.onTapGesture(perform: {
				swap(&a, &b)
				angle += 180
			})
	}
}
