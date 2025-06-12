# wezterm keybindings

```txt
Default key table
-----------------

 CTRL                 Tab                ->   ActivateTabRelative(1)
 SHIFT | CTRL         Tab                ->   ActivateTabRelative(-1)
 ALT                  Enter              ->   ToggleFullScreen
 CTRL                 !                  ->   ActivateTab(0)
 SHIFT | CTRL         !                  ->   ActivateTab(0)
 ALT | CTRL           "                  ->   SplitVertical(SpawnCommand domain=CurrentPaneDomain)
 SHIFT | ALT | CTRL   "                  ->   SplitVertical(SpawnCommand domain=CurrentPaneDomain)
 CTRL                 #                  ->   ActivateTab(2)
 SHIFT | CTRL         #                  ->   ActivateTab(2)
 CTRL                 $                  ->   ActivateTab(3)
 SHIFT | CTRL         $                  ->   ActivateTab(3)
 CTRL                 %                  ->   ActivateTab(4)
 SHIFT | CTRL         %                  ->   ActivateTab(4)
 ALT | CTRL           %                  ->   SplitHorizontal(SpawnCommand domain=CurrentPaneDomain)
 SHIFT | ALT | CTRL   %                  ->   SplitHorizontal(SpawnCommand domain=CurrentPaneDomain)
 CTRL                 &                  ->   ActivateTab(6)
 SHIFT | CTRL         &                  ->   ActivateTab(6)
 SHIFT | ALT | CTRL   '                  ->   SplitVertical(SpawnCommand domain=CurrentPaneDomain)
 CTRL                 (                  ->   ActivateTab(-1)
 SHIFT | CTRL         (                  ->   ActivateTab(-1)
 CTRL                 )                  ->   ResetFontSize
 SHIFT | CTRL         )                  ->   ResetFontSize
 CTRL                 *                  ->   ActivateTab(7)
 SHIFT | CTRL         *                  ->   ActivateTab(7)
 CTRL                 +                  ->   IncreaseFontSize
 SHIFT | CTRL         +                  ->   IncreaseFontSize
 CTRL                 -                  ->   DecreaseFontSize
 SHIFT | CTRL         -                  ->   DecreaseFontSize
 SUPER                -                  ->   DecreaseFontSize
 CTRL                 0                  ->   ResetFontSize
 SHIFT | CTRL         0                  ->   ResetFontSize
 SUPER                0                  ->   ResetFontSize
 SHIFT | CTRL         1                  ->   ActivateTab(0)
 SUPER                1                  ->   ActivateTab(0)
 SHIFT | CTRL         2                  ->   ActivateTab(1)
 SUPER                2                  ->   ActivateTab(1)
 SHIFT | CTRL         3                  ->   ActivateTab(2)
 SUPER                3                  ->   ActivateTab(2)
 SHIFT | CTRL         4                  ->   ActivateTab(3)
 SUPER                4                  ->   ActivateTab(3)
 SHIFT | CTRL         5                  ->   ActivateTab(4)
 SHIFT | ALT | CTRL   5                  ->   SplitHorizontal(SpawnCommand domain=CurrentPaneDomain)
 SUPER                5                  ->   ActivateTab(4)
 SHIFT | CTRL         6                  ->   ActivateTab(5)
 SUPER                6                  ->   ActivateTab(5)
 SHIFT | CTRL         7                  ->   ActivateTab(6)
 SUPER                7                  ->   ActivateTab(6)
 SHIFT | CTRL         8                  ->   ActivateTab(7)
 SUPER                8                  ->   ActivateTab(7)
 SHIFT | CTRL         9                  ->   ActivateTab(-1)
 SUPER                9                  ->   ActivateTab(-1)
 CTRL                 =                  ->   IncreaseFontSize
 SHIFT | CTRL         =                  ->   IncreaseFontSize
 SUPER                =                  ->   IncreaseFontSize
 CTRL                 @                  ->   ActivateTab(1)
 SHIFT | CTRL         @                  ->   ActivateTab(1)
 CTRL                 C                  ->   CopyTo(Clipboard)
 SHIFT | CTRL         C                  ->   CopyTo(Clipboard)
 CTRL                 F                  ->   Search(CurrentSelectionOrEmptyString)
 SHIFT | CTRL         F                  ->   Search(CurrentSelectionOrEmptyString)
 CTRL                 H                  ->   HideApplication
 SHIFT | CTRL         H                  ->   HideApplication
 CTRL                 K                  ->   ClearScrollback(ScrollbackOnly)
 SHIFT | CTRL         K                  ->   ClearScrollback(ScrollbackOnly)
 CTRL                 L                  ->   ShowDebugOverlay
 SHIFT | CTRL         L                  ->   ShowDebugOverlay
 CTRL                 M                  ->   Hide
 SHIFT | CTRL         M                  ->   Hide
 CTRL                 N                  ->   SpawnWindow
 SHIFT | CTRL         N                  ->   SpawnWindow
 CTRL                 P                  ->   ActivateCommandPalette
 SHIFT | CTRL         P                  ->   ActivateCommandPalette
 CTRL                 Q                  ->   QuitApplication
 SHIFT | CTRL         Q                  ->   QuitApplication
 CTRL                 R                  ->   ReloadConfiguration
 SHIFT | CTRL         R                  ->   ReloadConfiguration
 CTRL                 T                  ->   SpawnTab(CurrentPaneDomain)
 SHIFT | CTRL         T                  ->   SpawnTab(CurrentPaneDomain)
 CTRL                 U                  ->   CharSelect(CharSelectArguments { group: None, copy_on_select: true, copy_to: ClipboardAndPrimarySelection })
 SHIFT | CTRL         U                  ->   CharSelect(CharSelectArguments { group: None, copy_on_select: true, copy_to: ClipboardAndPrimarySelection })
 CTRL                 V                  ->   PasteFrom(Clipboard)
 SHIFT | CTRL         V                  ->   PasteFrom(Clipboard)
 CTRL                 W                  ->   CloseCurrentTab { confirm: true }
 SHIFT | CTRL         W                  ->   CloseCurrentTab { confirm: true }
 CTRL                 X                  ->   ActivateCopyMode
 SHIFT | CTRL         X                  ->   ActivateCopyMode
 CTRL                 Z                  ->   TogglePaneZoomState
 SHIFT | CTRL         Z                  ->   TogglePaneZoomState
 SHIFT | SUPER        [                  ->   ActivateTabRelative(-1)
 SHIFT | SUPER        ]                  ->   ActivateTabRelative(1)
 CTRL                 ^                  ->   ActivateTab(5)
 SHIFT | CTRL         ^                  ->   ActivateTab(5)
 CTRL                 _                  ->   DecreaseFontSize
 SHIFT | CTRL         _                  ->   DecreaseFontSize
 SHIFT | CTRL         c                  ->   CopyTo(Clipboard)
 SUPER                c                  ->   CopyTo(Clipboard)
 SHIFT | CTRL         f                  ->   Search(CurrentSelectionOrEmptyString)
 SUPER                f                  ->   Search(CurrentSelectionOrEmptyString)
 SHIFT | CTRL         h                  ->   HideApplication
 SUPER                h                  ->   HideApplication
 SHIFT | CTRL         k                  ->   ClearScrollback(ScrollbackOnly)
 SUPER                k                  ->   ClearScrollback(ScrollbackOnly)
 SHIFT | CTRL         l                  ->   ShowDebugOverlay
 SHIFT | CTRL         m                  ->   Hide
 SUPER                m                  ->   Hide
 SHIFT | CTRL         n                  ->   SpawnWindow
 SUPER                n                  ->   SpawnWindow
 SHIFT | CTRL         p                  ->   ActivateCommandPalette
 SHIFT | CTRL         q                  ->   QuitApplication
 SUPER                q                  ->   QuitApplication
 SHIFT | CTRL         r                  ->   ReloadConfiguration
 SUPER                r                  ->   ReloadConfiguration
 SHIFT | CTRL         t                  ->   SpawnTab(CurrentPaneDomain)
 SUPER                t                  ->   SpawnTab(CurrentPaneDomain)
 SHIFT | CTRL         u                  ->   CharSelect(CharSelectArguments { group: None, copy_on_select: true, copy_to: ClipboardAndPrimarySelection })
 SHIFT | CTRL         v                  ->   PasteFrom(Clipboard)
 SUPER                v                  ->   PasteFrom(Clipboard)
 SHIFT | CTRL         w                  ->   CloseCurrentTab { confirm: true }
 SUPER                w                  ->   CloseCurrentTab { confirm: true }
 SHIFT | CTRL         x                  ->   ActivateCopyMode
 SHIFT | CTRL         z                  ->   TogglePaneZoomState
 SUPER                {                  ->   ActivateTabRelative(-1)
 SHIFT | SUPER        {                  ->   ActivateTabRelative(-1)
 SUPER                }                  ->   ActivateTabRelative(1)
 SHIFT | SUPER        }                  ->   ActivateTabRelative(1)
 SHIFT | CTRL         Space (Physical)   ->   QuickSelect
 SHIFT                PageUp             ->   ScrollByPage(NotNan(-1.0))
 CTRL                 PageUp             ->   ActivateTabRelative(-1)
 SHIFT | CTRL         PageUp             ->   MoveTabRelative(-1)
 SHIFT                PageDown           ->   ScrollByPage(NotNan(1.0))
 CTRL                 PageDown           ->   ActivateTabRelative(1)
 SHIFT | CTRL         PageDown           ->   MoveTabRelative(1)
 SHIFT | CTRL         LeftArrow          ->   ActivatePaneDirection(Left)
 SHIFT | ALT | CTRL   LeftArrow          ->   AdjustPaneSize(Left, 1)
 SHIFT | CTRL         RightArrow         ->   ActivatePaneDirection(Right)
 SHIFT | ALT | CTRL   RightArrow         ->   AdjustPaneSize(Right, 1)
 SHIFT | CTRL         UpArrow            ->   ActivatePaneDirection(Up)
 SHIFT | ALT | CTRL   UpArrow            ->   AdjustPaneSize(Up, 1)
 SHIFT | CTRL         DownArrow          ->   ActivatePaneDirection(Down)
 SHIFT | ALT | CTRL   DownArrow          ->   AdjustPaneSize(Down, 1)
                      Copy               ->   CopyTo(Clipboard)
                      Paste              ->   PasteFrom(Clipboard)

Key Table: copy_mode
--------------------

         Tab          ->   CopyMode(MoveForwardWord)
 SHIFT   Tab          ->   CopyMode(MoveBackwardWord)
         Enter        ->   CopyMode(MoveToStartOfNextLine)
         Escape       ->   CopyMode(Close)
         Space        ->   CopyMode(SetSelectionMode(Some(Cell)))
         $            ->   CopyMode(MoveToEndOfLineContent)
 SHIFT   $            ->   CopyMode(MoveToEndOfLineContent)
         ,            ->   CopyMode(JumpReverse)
         0            ->   CopyMode(MoveToStartOfLine)
         ;            ->   CopyMode(JumpAgain)
         F            ->   CopyMode(JumpBackward { prev_char: false })
 SHIFT   F            ->   CopyMode(JumpBackward { prev_char: false })
         G            ->   CopyMode(MoveToScrollbackBottom)
 SHIFT   G            ->   CopyMode(MoveToScrollbackBottom)
         H            ->   CopyMode(MoveToViewportTop)
 SHIFT   H            ->   CopyMode(MoveToViewportTop)
         L            ->   CopyMode(MoveToViewportBottom)
 SHIFT   L            ->   CopyMode(MoveToViewportBottom)
         M            ->   CopyMode(MoveToViewportMiddle)
 SHIFT   M            ->   CopyMode(MoveToViewportMiddle)
         O            ->   CopyMode(MoveToSelectionOtherEndHoriz)
 SHIFT   O            ->   CopyMode(MoveToSelectionOtherEndHoriz)
         T            ->   CopyMode(JumpBackward { prev_char: true })
 SHIFT   T            ->   CopyMode(JumpBackward { prev_char: true })
         V            ->   CopyMode(SetSelectionMode(Some(Line)))
 SHIFT   V            ->   CopyMode(SetSelectionMode(Some(Line)))
         ^            ->   CopyMode(MoveToStartOfLineContent)
 SHIFT   ^            ->   CopyMode(MoveToStartOfLineContent)
         b            ->   CopyMode(MoveBackwardWord)
 ALT     b            ->   CopyMode(MoveBackwardWord)
 CTRL    b            ->   CopyMode(PageUp)
 CTRL    c            ->   CopyMode(Close)
 CTRL    d            ->   CopyMode(MoveByPage(NotNan(0.5)))
         e            ->   CopyMode(MoveForwardWordEnd)
         f            ->   CopyMode(JumpForward { prev_char: false })
 ALT     f            ->   CopyMode(MoveForwardWord)
 CTRL    f            ->   CopyMode(PageDown)
         g            ->   CopyMode(MoveToScrollbackTop)
 CTRL    g            ->   CopyMode(Close)
         h            ->   CopyMode(MoveLeft)
         j            ->   CopyMode(MoveDown)
         k            ->   CopyMode(MoveUp)
         l            ->   CopyMode(MoveRight)
 ALT     m            ->   CopyMode(MoveToStartOfLineContent)
         o            ->   CopyMode(MoveToSelectionOtherEnd)
         q            ->   CopyMode(Close)
         t            ->   CopyMode(JumpForward { prev_char: true })
 CTRL    u            ->   CopyMode(MoveByPage(NotNan(-0.5)))
         v            ->   CopyMode(SetSelectionMode(Some(Cell)))
 CTRL    v            ->   CopyMode(SetSelectionMode(Some(Block)))
         w            ->   CopyMode(MoveForwardWord)
         y            ->   Multiple([CopyTo(ClipboardAndPrimarySelection), CopyMode(Close)])
         PageUp       ->   CopyMode(PageUp)
         PageDown     ->   CopyMode(PageDown)
         End          ->   CopyMode(MoveToEndOfLineContent)
         Home         ->   CopyMode(MoveToStartOfLine)
         LeftArrow    ->   CopyMode(MoveLeft)
 ALT     LeftArrow    ->   CopyMode(MoveBackwardWord)
         RightArrow   ->   CopyMode(MoveRight)
 ALT     RightArrow   ->   CopyMode(MoveForwardWord)
         UpArrow      ->   CopyMode(MoveUp)
         DownArrow    ->   CopyMode(MoveDown)

Key Table: search_mode
----------------------

        Enter       ->   CopyMode(PriorMatch)
        Escape      ->   CopyMode(Close)
 CTRL   n           ->   CopyMode(NextMatch)
 CTRL   p           ->   CopyMode(PriorMatch)
 CTRL   r           ->   CopyMode(CycleMatchType)
 CTRL   u           ->   CopyMode(ClearPattern)
        PageUp      ->   CopyMode(PriorMatchPage)
        PageDown    ->   CopyMode(NextMatchPage)
        UpArrow     ->   CopyMode(PriorMatch)
        DownArrow   ->   CopyMode(NextMatch)

Mouse
-----

                Down { streak: 1, button: Left }           ->   SelectTextAtMouseCursor(Cell)
 SHIFT          Down { streak: 1, button: Left }           ->   ExtendSelectionToMouseCursor(Cell)
 ALT            Down { streak: 1, button: Left }           ->   SelectTextAtMouseCursor(Block)
 SHIFT | ALT    Down { streak: 1, button: Left }           ->   ExtendSelectionToMouseCursor(Block)
                Down { streak: 1, button: Middle }         ->   PasteFrom(PrimarySelection)
                Down { streak: 1, button: WheelUp(1) }     ->   ScrollByCurrentEventWheelDelta
                Down { streak: 1, button: WheelDown(1) }   ->   ScrollByCurrentEventWheelDelta
                Down { streak: 2, button: Left }           ->   SelectTextAtMouseCursor(Word)
                Down { streak: 3, button: Left }           ->   SelectTextAtMouseCursor(Line)
                Drag { streak: 1, button: Left }           ->   ExtendSelectionToMouseCursor(Cell)
 ALT            Drag { streak: 1, button: Left }           ->   ExtendSelectionToMouseCursor(Block)
 SHIFT | CTRL   Drag { streak: 1, button: Left }           ->   StartWindowDrag
 SUPER          Drag { streak: 1, button: Left }           ->   StartWindowDrag
                Drag { streak: 2, button: Left }           ->   ExtendSelectionToMouseCursor(Word)
                Drag { streak: 3, button: Left }           ->   ExtendSelectionToMouseCursor(Line)
                Up { streak: 1, button: Left }             ->   CompleteSelectionOrOpenLinkAtMouseCursor(ClipboardAndPrimarySelection)
 SHIFT          Up { streak: 1, button: Left }             ->   CompleteSelectionOrOpenLinkAtMouseCursor(ClipboardAndPrimarySelection)
 ALT            Up { streak: 1, button: Left }             ->   CompleteSelection(ClipboardAndPrimarySelection)
 SHIFT | ALT    Up { streak: 1, button: Left }             ->   CompleteSelectionOrOpenLinkAtMouseCursor(PrimarySelection)
                Up { streak: 2, button: Left }             ->   CompleteSelection(ClipboardAndPrimarySelection)
                Up { streak: 3, button: Left }             ->   CompleteSelection(ClipboardAndPrimarySelection)

Mouse: alt_screen
-----------------

                Down { streak: 1, button: Left }     ->   SelectTextAtMouseCursor(Cell)
 SHIFT          Down { streak: 1, button: Left }     ->   ExtendSelectionToMouseCursor(Cell)
 ALT            Down { streak: 1, button: Left }     ->   SelectTextAtMouseCursor(Block)
 SHIFT | ALT    Down { streak: 1, button: Left }     ->   ExtendSelectionToMouseCursor(Block)
                Down { streak: 1, button: Middle }   ->   PasteFrom(PrimarySelection)
                Down { streak: 2, button: Left }     ->   SelectTextAtMouseCursor(Word)
                Down { streak: 3, button: Left }     ->   SelectTextAtMouseCursor(Line)
                Drag { streak: 1, button: Left }     ->   ExtendSelectionToMouseCursor(Cell)
 ALT            Drag { streak: 1, button: Left }     ->   ExtendSelectionToMouseCursor(Block)
 SHIFT | CTRL   Drag { streak: 1, button: Left }     ->   StartWindowDrag
 SUPER          Drag { streak: 1, button: Left }     ->   StartWindowDrag
                Drag { streak: 2, button: Left }     ->   ExtendSelectionToMouseCursor(Word)
                Drag { streak: 3, button: Left }     ->   ExtendSelectionToMouseCursor(Line)
                Up { streak: 1, button: Left }       ->   CompleteSelectionOrOpenLinkAtMouseCursor(ClipboardAndPrimarySelection)
 SHIFT          Up { streak: 1, button: Left }       ->   CompleteSelectionOrOpenLinkAtMouseCursor(ClipboardAndPrimarySelection)
 ALT            Up { streak: 1, button: Left }       ->   CompleteSelection(ClipboardAndPrimarySelection)
 SHIFT | ALT    Up { streak: 1, button: Left }       ->   CompleteSelectionOrOpenLinkAtMouseCursor(PrimarySelection)
                Up { streak: 2, button: Left }       ->   CompleteSelection(ClipboardAndPrimarySelection)
                Up { streak: 3, button: Left }       ->   CompleteSelection(ClipboardAndPrimarySelection)

```

- Generated on Thu 2 Jan 2025 17:41:13 EET
