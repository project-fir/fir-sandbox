module Evergreen.V62.EditorMsg exposing (..)

import Browser.Dom
import ContextMenu
import Debounce
import Evergreen.V62.Vim
import File
import Markdown.Render


type alias Position =
    { line : Int
    , column : Int
    }


type Hover
    = NoHover
    | HoverLine Int
    | HoverChar Position


type Selection
    = NoSelection
    | SelectingFrom Hover
    | SelectedChar Position
    | Selection Position Position


type Context
    = Object
    | Background


type WrapOption
    = DoWrap
    | DontWrap


type EMsg
    = EditorNoOp
    | ExitVimInsertMode
    | MoveUp
    | MoveDown
    | MoveLeft
    | MoveRight
    | MoveToLineStart
    | MoveToLineEnd
    | PageUp
    | PageDown
    | FirstLine
    | LastLine
    | GoToLine
    | NewLine
    | InsertChar String
    | Indent
    | Deindent
    | RemoveCharBefore
    | RemoveCharAfter
    | KillLine
    | KillLineAlt
    | DeleteLine
    | Cut
    | Copy
    | Paste
    | WrapAll
    | WrapSelection
    | Hover Hover
    | GoToHoveredPosition
    | StartSelecting
    | StopSelecting
    | SelectLine
    | SelectUp
    | SelectDown
    | SelectLeft
    | SelectRight
    | SelectGroup
    | Undo
    | Redo
    | AcceptLineToGoTo String
    | DebounceMsg Debounce.Msg
    | Unload String
    | Clear
    | Test
    | ContextMenuMsg (ContextMenu.Msg Context)
    | Item Int
    | ToggleAutoLineBreak
    | EditorRequestFile
    | EditorRequestedFile File.File
    | MarkdownLoaded String
    | EditorSaveFile
    | SendLineForLRSync
    | GotViewportForSync (Maybe String) Selection (Result Browser.Dom.Error Browser.Dom.Viewport)
    | ViewportMotion (Result Browser.Dom.Error ())
    | GotViewportInfo (Result Browser.Dom.Error Browser.Dom.Viewport)
    | CopyPasteClipboard
    | WriteToSystemClipBoard
    | DoSearch String
    | ToggleSearchPanel
    | ToggleReplacePanel
    | OpenReplaceField
    | RollSearchSelectionForward
    | RollSearchSelectionBackward
    | ReplaceCurrentSelection
    | AcceptLineNumber String
    | AcceptSearchText String
    | AcceptReplacementText String
    | GotViewport (Result Browser.Dom.Error Browser.Dom.Viewport)
    | ToggleDarkMode
    | ToggleHelp
    | ToggleEditMode
    | ToggleShortCutExecution
    | MarkdownMsg Markdown.Render.MarkdownMsg
    | Vim Evergreen.V62.Vim.VimMsg
