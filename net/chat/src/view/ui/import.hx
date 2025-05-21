package view.ui;

import lime.ui.FileDialog;
import lime.ui.FileDialogType;

import peote.view.Color;

import view.ui.Fnt;
import view.ui.Fnt.TextLine;
import view.ui.Fnt.TextPage;

import peote.ui.PeoteUIDisplay;

import peote.ui.interactive.UIElement;
import peote.ui.interactive.UIArea;
import peote.ui.interactive.UISlider;
import peote.ui.interactive.interfaces.ParentElement;

import peote.ui.style.BoxStyle;
import peote.ui.style.RoundBorderStyle;
import peote.ui.style.FontStyleTiled;
import peote.ui.style.interfaces.Style;

import peote.ui.config.TextConfig;
import peote.ui.config.AreaConfig;
import peote.ui.config.SliderConfig;
import peote.ui.config.ResizeType;
import peote.ui.config.Space;
import peote.ui.config.HAlign;
import peote.ui.config.VAlign;


import peote.ui.event.PointerEvent;
import peote.ui.event.WheelEvent;

import input2action.Input2Action;
import input2action.ActionConfig;
import input2action.ActionMap;
import input2action.KeyboardAction;
import peote.ui.interactive.input2action.InputTextLine;
import lime.ui.KeyCode;

// --- peote-ui-extra lib ----
// import peote.ui.extra.UIAreaList;
// import peote.ui.extra.LogArea;
// import peote.ui.extra.LogAreaConfig;

