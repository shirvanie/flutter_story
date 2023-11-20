import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Story extends StatefulWidget {
  const Story({
    super.key,
    this.controller,
    this.autoplay = true,
    this.height = 130,
    this.color = Colors.transparent,
    this.backgroundColor,
    this.padding = const EdgeInsets.all(5),
    this.shrinkWrap = true,
    this.physics = const BouncingScrollPhysics(),
    this.reverse = false,
    this.scrollDirection = Axis.horizontal,
    this.scrollController,
    this.children = const <StoryUser>[],
    this.sortByVisited = false,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
  })  : itemBuilder = null,
        findChildIndexCallback = null,
        itemCount = null;

  const Story.builder({
    super.key,
    this.controller,
    this.autoplay = true,
    this.height = 130,
    this.color = Colors.transparent,
    this.backgroundColor,
    this.padding = const EdgeInsets.all(5),
    this.shrinkWrap = true,
    this.physics = const BouncingScrollPhysics(),
    this.reverse = false,
    this.scrollDirection = Axis.horizontal,
    this.scrollController,
    this.children = const <StoryUser>[],
    this.itemBuilder,
    this.sortByVisited = false,
    this.findChildIndexCallback,
    this.itemCount,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
  })  : assert(itemCount == null || itemCount >= 0),
        assert(
          itemBuilder == null || itemCount != null,
          "Both [itemBuilder] and [itemCount] must be non-null",
        );

  /// It can be used to control the state of [Story].
  final StoryController? controller;

  /// Allows autoplaying of [Story].
  /// if set this to false, the [Story] does not play.
  final bool autoplay;

  /// The [height] of the [Story].
  final double height;

  /// The [color] to fill the [Story].
  final Color? color;

  /// The color to fill the [backgroundColor] of the [Story].
  final Color? backgroundColor;

  /// The [padding] of the [Story].
  final EdgeInsets? padding;

  /// Whether the extent of the scroll view in the [scrollDirection] should be
  /// determined by the contents being viewed.
  final bool shrinkWrap;

  /// How the scroll view should respond to user input.
  /// For example, determines how the scroll view continues to animate after the
  /// user stops dragging the scroll view.
  final ScrollPhysics? physics;

  /// Whether the scroll view scrolls in the reading direction.
  /// For example, if the reading direction is left-to-right and
  /// [scrollDirection] is [Axis.horizontal], then the scroll view scrolls from
  /// left to right when [reverse] is false and from right to left when
  /// [reverse] is true.
  final bool reverse;

  /// The [Axis] along which the scroll view's offset increases.
  /// For the direction in which active scrolling may be occurring, see
  /// [ScrollDirection].
  /// Defaults to [Axis.horizontal].
  final Axis scrollDirection;

  /// An object that can be used to control the position to which this scroll
  /// view is scrolled.
  /// A [ScrollController] serves several purposes. It can be used to control.
  final ScrollController? scrollController;

  /// Creates a list of the [StoryUser] layout widget.
  /// By default, the non-positioned children of the [Story] are aligned by
  /// their top left corners.
  final List<StoryUser> children;

  /// Creates a scrollable, linear array of widgets that are created on demand.
  /// This constructor is appropriate for list views with a large (or infinite)
  /// number of children because the builder is called only for those children
  /// that are actually visible.
  /// Providing a non-null itemCount improves the ability of the ListView to
  /// estimate the maximum scroll extent.
  /// The itemBuilder callback will be called only with indices greater than or
  /// equal to zero and less than itemCount.
  final StoryUser? Function(BuildContext, int)? itemBuilder;

  /// If set to true, The list of [Story] sorts by [StoryCard.visited].
  final bool sortByVisited;

  /// Called to find the new index of a child based on its key in case of
  /// reordering.
  /// If not provided, a child widget may not map to its existing [RenderObject]
  /// when the order of children returned from the children builder changes.
  /// This may result in state-loss.
  /// This callback should take an input [Key], and it should return the
  /// index of the child element with that associated key, or null if not found.
  final ChildIndexGetter? findChildIndexCallback;

  /// Creates a scrollable, linear array of widgets that are created on demand.
  /// This constructor is appropriate for list views with a large (or infinite)
  /// number of children because the builder is called only for those children
  /// that are actually visible. Providing a non-null itemCount improves
  /// the ability of the ListView to estimate the maximum scroll extent.
  /// The itemBuilder callback will be called only with indices greater than or
  /// equal to zero and less than itemCount.
  final int? itemCount;

  /// Whether to wrap each child in an [AutomaticKeepAlive].
  /// Typically, children in lazy list are wrapped in [AutomaticKeepAlive]
  /// widgets so that children can use [KeepAliveNotification]s to preserve
  /// their state when they would otherwise be garbage collected off-screen.
  /// This feature (and [addRepaintBoundaries]) must be disabled if the children
  /// are going to manually maintain their [KeepAlive] state. It may also be
  /// more efficient to disable this feature if it is known ahead of time that
  /// none of the children will ever try to keep themselves alive.
  /// Defaults to true.
  final bool addAutomaticKeepAlives;

  /// Whether to wrap each child in a [RepaintBoundary].
  /// Typically, children in a scrolling container are wrapped in repaint
  /// boundaries so that they do not need to be repainted as the list scrolls.
  /// If the children are easy to repaint (e.g., solid color blocks or a short
  /// snippet of text), it might be more efficient to not add a repaint boundary
  /// and instead always repaint the children during scrolling.
  /// Defaults to true.
  final bool addRepaintBoundaries;

  /// Whether to wrap each child in an [IndexedSemantics].
  /// Typically, children in a scrolling container must be annotated with a
  /// semantic index in order to generate the correct accessibility
  /// announcements. This should only be set to false if the indexes have
  /// already been provided by an [IndexedSemantics] widget.
  /// Defaults to true.
  final bool addSemanticIndexes;

  @override
  State<Story> createState() => _StoryState();
}

class _StoryState extends State<Story> {
  final GlobalKey _storyboardKey = GlobalKey();
  List<StoryUser> _children = [];
  late bool _autoplay;
  ValueChanged<bool>? _autoplayNotifier;

  @override
  void initState() {
    super.initState();
    _autoplay = widget.autoplay;
    if (widget.controller != null) widget.controller!._addState(this);
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    _children = _orderByVisited();
    List<StoryUser> childrenNotVisited =
        _children.where((e) => e.children.any((e) => !e.visited)).toList();
    List<StoryUser> childrenAllVisited =
        _children.where((e) => !e.children.any((e) => !e.visited)).toList();
    return SingleChildScrollView(
      child: Builder(builder: (context) {
        return Container(
          color: widget.backgroundColor,
          width: widget.scrollDirection == Axis.vertical ? widget.height : null,
          height:
              widget.scrollDirection == Axis.vertical ? null : widget.height,
          child: ListView.builder(
            controller: widget.scrollController,
            scrollDirection: widget.scrollDirection,
            physics: widget.physics,
            padding: widget.padding,
            shrinkWrap: widget.shrinkWrap,
            itemCount: _children.length,
            reverse: widget.reverse,
            addAutomaticKeepAlives: widget.addAutomaticKeepAlives,
            addRepaintBoundaries: widget.addRepaintBoundaries,
            addSemanticIndexes: widget.addSemanticIndexes,
            findChildIndexCallback: widget.findChildIndexCallback,
            itemBuilder: (_, index) {
              StoryUser s = _children[index];
              return Builder(builder: (context) {
                return StoryUser(
                  key: s.key,
                  width: s.width,
                  height: s.height,
                  margin: s.margin,
                  avatarColor: s.avatarColor,
                  borderWidth: s.borderWidth,
                  borderColor: s.borderColor,
                  borderPadding: s.borderPadding,
                  borderRadius: s.borderRadius,
                  avatar: s.avatar,
                  label: s.label,
                  onPressed: (storyIndex) {
                    if (s.children.isNotEmpty) {
                      Offset offset = _getStoryUserPosition(
                          context, screenWidth, screenHeight);
                      Navigator.push(
                              context,
                              _StoryPageRoute(
                                  startPosition: offset,
                                  backgroundColor: widget.color,
                                  page: _Storyboard(
                                      key: _storyboardKey,
                                      storyController: widget.controller,
                                      autoplay: widget.autoplay,
                                      storyIndex: !widget.sortByVisited
                                          ? index
                                          : index < childrenNotVisited.length
                                              ? index
                                              : index -
                                                  (childrenNotVisited.length),
                                      cardIndex: null,
                                      allCardVisited: !widget.sortByVisited
                                          ? s.children
                                                      .where((x) => x.visited)
                                                      .length ==
                                                  s.children.length
                                              ? true
                                              : false
                                          : index >= childrenNotVisited.length,
                                      children: !widget.sortByVisited
                                          ? _children
                                          : index < childrenNotVisited.length
                                              ? childrenNotVisited
                                              : childrenAllVisited)))
                          .then((_) => _autoplay = widget.autoplay);
                    }
                    s.onPressed?.call(index);
                  },
                  onLongPressed: (_) => s.onLongPressed?.call(index),
                  children: s.children,
                );
              });
            },
          ),
        );
      }),
    );
  }

  /// Orders the [StoryUser] by [StoryCard.visited].
  List<StoryUser> _orderByVisited() {
    List<StoryUser> children = [];
    if (widget.itemBuilder != null) {
      List<StoryUser> childrenBuilder = [];
      for (int i = 0; i < widget.itemCount!; i++) {
        childrenBuilder.add(widget.itemBuilder!.call(context, i)!);
      }
      if (!widget.sortByVisited) {
        children.addAll(childrenBuilder);
      } else {
        children.addAll(childrenBuilder
            .where((e) => e.children.any((e) => !e.visited))
            .toList());
        children.addAll(childrenBuilder
            .where((e) => !e.children.any((e) => !e.visited))
            .toList());
      }
    } else {
      if (!widget.sortByVisited) {
        children.addAll(widget.children);
      } else {
        children.addAll(widget.children
            .where((e) => e.children.any((e) => !e.visited))
            .toList());
        children.addAll(widget.children
            .where((e) => !e.children.any((e) => !e.visited))
            .toList());
      }
    }
    return children;
  }

  /// Pauses the [Story].
  void _pauseStory() {
    if (_storyboardKey.currentContext == null) return;
    if (mounted) {
      setState(() {
        _autoplay = false;
      });
    }
    _autoplayNotifier?.call(_autoplay);
  }

  /// Plays the [Story].
  void _playStory() {
    if (_storyboardKey.currentContext == null) return;
    if (mounted) {
      setState(() {
        _autoplay = true;
      });
    }
    _autoplayNotifier?.call(_autoplay);
  }

  /// Closes the [Story].
  void _closeStory() {
    if (_storyboardKey.currentContext == null) return;
    Navigator.pop(_storyboardKey.currentContext!);
  }

  /// Opens the [Story].
  /// If the [cardIndex] null, default [cardIndex] is not [StoryCard.visited].
  Future<void> _openStory(
      BuildContext context, int storyIndex, int? cardIndex) {
    assert(storyIndex >= 0 && storyIndex < _children.length);
    assert(cardIndex == null ||
        (cardIndex >= 0 && cardIndex < _children[storyIndex].children.length));
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    Offset offset = _getStoryUserPosition(context, screenWidth, screenHeight);
    if (cardIndex != null) {
      for (int i = 0; i < cardIndex; i++) {
        _setStoryCardVisited(storyIndex, i, true);
      }
      for (int i = cardIndex; i < _children[storyIndex].children.length; i++) {
        _setStoryCardVisited(storyIndex, i, false);
      }
    }
    List<StoryUser> childrenNotVisited =
        _children.where((e) => e.children.any((e) => !e.visited)).toList();
    return Navigator.push(
        context,
        _StoryPageRoute(
            startPosition: offset,
            backgroundColor: widget.color,
            page: _Storyboard(
              key: _storyboardKey,
              storyController: widget.controller,
              autoplay: widget.autoplay,
              storyIndex: 0,
              cardIndex: cardIndex,
              allCardVisited: !widget.sortByVisited
                  ? storyIndex >= _children.length
                  : storyIndex >= childrenNotVisited.length,
              children: [_children[storyIndex]],
            ))).then((_) => _autoplay = widget.autoplay);
  }

  /// Opens the [Story] by [StoryUser.userId].
  Future<void> _openStoryByUserId(
      BuildContext context, int userId, int? cardIndex) {
    assert(_children.any((e) => e.userId == userId));
    assert(cardIndex == null ||
        (cardIndex >= 0 &&
            cardIndex <
                _children
                    .firstWhere((e) => e.userId == userId)
                    .children
                    .length));
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    Offset offset = _getStoryUserPosition(context, screenWidth, screenHeight);
    List<StoryUser> children = [
      _children.firstWhere((e) => e.userId == userId)
    ];
    int storyIndex = 0;
    for (int i = 0; i < _children.length; i++) {
      if (_children[i].userId == userId) storyIndex = i;
    }
    if (cardIndex != null) {
      for (int i = 0; i < cardIndex; i++) {
        _setStoryCardVisited(storyIndex, i, true);
      }
      for (int i = cardIndex; i < children.first.children.length; i++) {
        _setStoryCardVisited(storyIndex, i, false);
      }
    }
    List<StoryUser> childrenNotVisited =
        children.where((e) => e.children.any((e) => !e.visited)).toList();
    return Navigator.push(
        context,
        _StoryPageRoute(
            startPosition: offset,
            backgroundColor: widget.color,
            page: _Storyboard(
              key: _storyboardKey,
              storyController: widget.controller,
              autoplay: widget.autoplay,
              storyIndex: 0,
              cardIndex: cardIndex,
              allCardVisited: !widget.sortByVisited
                  ? children.isEmpty
                  : childrenNotVisited.isEmpty,
              children: children,
            ))).then((_) => _autoplay = widget.autoplay);
  }

  /// Gets offset of [StoryUser] widget position.
  Offset _getStoryUserPosition(
      BuildContext context, double screenWidth, double screenHeight) {
    RenderBox box = context.findRenderObject() as RenderBox;

    /// This is global position.
    Offset offset = box.localToGlobal(Offset.zero);

    /// Center position of the StoryUser.
    double positionX = offset.dx + (box.size.width / 2);
    double positionY = offset.dy + (box.size.height / 3);

    /// Percentage of element position. like 60 percent of screen.
    double percentScreenX = (positionX * 100.0) / screenWidth;
    double percentScreenY = (positionY * 100.0) / screenHeight;

    /// between 0.0 and 1.0.
    double dx = percentScreenX / 100.0;

    /// between 0.0 and 1.0.
    double dy = percentScreenY / 100.0;
    return Offset(dx, dy);
  }

  /// Sets a value for the [StoryCard.visited].
  Future<void> _setStoryCardVisited(
      int storyIndex, int cardIndex, bool visited) async {
    assert(storyIndex >= 0 && storyIndex < _children.length);
    assert(cardIndex >= 0 && cardIndex < _children[storyIndex].children.length);
    StoryCard c = _children[storyIndex].children[cardIndex];
    _children[storyIndex].children[cardIndex] = StoryCard(
      key: c.key,
      visited: visited,
      cardDuration: c.cardDuration,
      color: c.color,
      borderRadius: c.borderRadius,
      progressBarHeight: c.progressBarHeight,
      onVisited: c.onVisited,
      onDispose: c.onDispose,
      onPause: c.onPause,
      onResume: c.onResume,
      onNext: c.onNext,
      onPrevious: c.onPrevious,
      footer: c.footer,
      childOverlay: c.childOverlay,
      child: c.child,
    );
  }

  /// Sets a value for the [StoryCard.visited] by [StoryUser.userId].
  Future<void> _setStoryCardVisitedByUserId(
      int userId, int cardIndex, bool visited) async {
    assert(_children.any((e) => e.userId == userId));
    assert(cardIndex >= 0 &&
        cardIndex <
            _children.firstWhere((e) => e.userId == userId).children.length);
    List<StoryUser> children = [
      _children.firstWhere((e) => e.userId == userId)
    ];
    StoryCard c = children.first.children[cardIndex];
    children.first.children[cardIndex] = StoryCard(
      key: c.key,
      visited: visited,
      cardDuration: c.cardDuration,
      color: c.color,
      borderRadius: c.borderRadius,
      progressBarHeight: c.progressBarHeight,
      onVisited: c.onVisited,
      onDispose: c.onDispose,
      onPause: c.onPause,
      onResume: c.onResume,
      onNext: c.onNext,
      onPrevious: c.onPrevious,
      footer: c.footer,
      childOverlay: c.childOverlay,
      child: c.child,
    );
  }
}

class StoryUser extends StatefulWidget {
  const StoryUser({
    super.key,
    this.userId,
    this.width = 86,
    this.height = 86,
    this.margin = const EdgeInsets.symmetric(vertical: 5, horizontal: 7),
    this.avatarColor = Colors.grey,
    this.borderWidth = 3,
    this.visitedBorderColor = const Color(0xFFDDDDDD),
    this.borderColor = Colors.deepOrange,
    this.borderPadding = const EdgeInsets.all(4),
    this.borderRadius = const BorderRadius.all(Radius.circular(43)),
    this.avatar,
    this.label,
    this.children = const [],
    this.onPressed,
    this.onLongPressed,
  });

  /// The [userId] of the [StoryUser].
  final int? userId;

  /// The [width] of the [StoryUser].
  final double width;

  /// The [height] of the [StoryUser].
  final double height;

  /// The [margin] of the [StoryUser].
  final EdgeInsets margin;

  /// The color to fill the background of the [StoryUser.avatar].
  final Color avatarColor;

  /// Determines the width of the [StoryUser] border.
  final double borderWidth;

  /// Determines the color of the [StoryUser] border.
  final Color borderColor;

  /// Determines the color of the [StoryCard] border,
  /// when all [StoryUser] child visited.
  final Color visitedBorderColor;

  /// The padding of the [StoryUser.avatar] border.
  final EdgeInsets borderPadding;

  /// If non-null, the corners of [StoryUser] are rounded by this.
  final BorderRadius borderRadius;

  /// The [avatar] of the [StoryUser].
  /// A Widget that is placed in the [StoryUser.avatar].
  final Widget? avatar;

  /// A Text Widget that is placed in bottomCenter of the [StoryUser.avatar].
  final Text? label;

  /// Creates a [StoryUser] layout widget.
  /// By default, the non-positioned children of the [StoryUser] are aligned by
  /// their top left corners.
  final List<StoryCard> children;

  /// This callback is called when pressed on the [StoryUser.avatar].
  /// Returns a index of the [StoryUser] list.
  final ValueChanged<int>? onPressed;

  /// This callback is called when long pressed on the [StoryUser.avatar].
  /// Returns a index of the [StoryUser] list.
  final ValueChanged<int>? onLongPressed;

  @override
  State<StoryUser> createState() => _StoryUserState();
}

class _StoryUserState extends State<StoryUser> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin:
          EdgeInsets.only(top: widget.margin.top, bottom: widget.margin.bottom),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(
                left: widget.margin.left, right: widget.margin.right),
            width: widget.width,
            height: widget.height,
            child: GestureDetector(
              onTap: () => widget.onPressed?.call(0),
              onLongPress: () => widget.onLongPressed?.call(0),
              child: Container(
                padding: widget.borderPadding,
                decoration: BoxDecoration(
                  border: widget.children.isEmpty
                      ? null
                      : Border.all(
                          width: widget.borderWidth,
                          color: widget.children.any((e) => !e.visited)
                              ? widget.borderColor
                              : widget.visitedBorderColor,
                        ),
                  borderRadius: widget.borderRadius,
                ),
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: widget.avatarColor,
                    borderRadius: widget.borderRadius,
                  ),
                  child: widget.avatar,
                ),
              ),
            ),
          ),
          if (widget.label != null)
            Container(
              width: widget.width,
              constraints: BoxConstraints(
                maxWidth:
                    widget.width + widget.margin.left + widget.margin.right,
              ),
              margin: const EdgeInsets.only(top: 4),
              child: widget.label!._toEllipsis._toCenter._toOneLine,
            )
        ],
      ),
    );
  }
}

class StoryCard extends StatefulWidget {
  const StoryCard({
    super.key,
    this.visited = false,
    this.cardDuration = const Duration(seconds: 3),
    this.color = const Color(0xFF333333),
    this.borderRadius = const BorderRadius.all(Radius.circular(10)),
    this.progressBarHeight = 5,
    this.onVisited,
    this.onDispose,
    this.onPause,
    this.onResume,
    this.onNext,
    this.onPrevious,
    this.footer,
    this.childOverlay,
    this.child,
  });

  /// If set true, the next card is displayed and all previous cards must be
  /// set true.
  /// If all are set false, they will be displayed from the first card.
  /// If all are set true, they will be displayed from the first card and
  /// its borderColor change to [StoryUser.borderColor].
  final bool visited;

  /// Determines the time to show the [StoryCard].
  final Duration cardDuration;

  /// The [color] of the [StoryCard] background.
  final Color color;

  /// If non-null, the corners of [StoryCard] are rounded by this.
  final BorderRadius borderRadius;

  /// The [progressBarHeight] of the [StoryCard] tab bar.
  final double progressBarHeight;

  /// This callback is called when [StoryCard] is visited.
  /// Returns a card index of the [StoryCard] list.
  final ValueChanged<int>? onVisited;

  /// This callback is called when [StoryCard] is dispose.
  /// Returns a card index of the [StoryCard] list.
  final ValueChanged<int>? onDispose;

  /// This callback is called when [StoryCard] is paused.
  /// Returns a card index of the [StoryCard] list.
  final ValueChanged<int>? onPause;

  /// This callback is called when [StoryCard] is played.
  /// Returns a card index of the [StoryCard] list.
  final ValueChanged<int>? onResume;

  /// This callback is called when next [StoryCard] is displayed.
  /// Returns a card index of the [StoryCard] list.
  final ValueChanged<int>? onNext;

  /// This callback is called when previous [StoryCard] is displayed.
  /// Returns a card index of the [StoryCard] list.
  final ValueChanged<int>? onPrevious;

  /// The [footer] of the [StoryCard].
  /// A Widget that is placed in bottom of the [StoryCard].
  final StoryCardFooter? footer;

  /// A Widget that is placed on the [StoryCard.child].
  final Widget? childOverlay;

  /// Creates a [StoryCard] layout widget.
  /// The widget below this widget in the tree.
  /// This widget can only have one child. To lay out multiple children,
  /// let this widget's child be a widget such as Row, Column, or Stack,
  /// which have a children property, and then provide the children to
  /// that widget.
  final Widget? child;

  @override
  State<StoryCard> createState() => _StoryCardState();
}

class _StoryCardState extends State<StoryCard> {
  @override
  Widget build(BuildContext context) {
    return Container(child: widget.child);
  }
}

class StoryCardFooter extends StatefulWidget {
  const StoryCardFooter({
    super.key,
    this.messageBox,
    this.likeButton,
    this.forwardButton,
    this.child,
  });

  /// If null, the [child] is displayed.
  final StoryCardMessageBox? messageBox;

  /// If non-null, the [likeButton] is placed in right of
  /// the [StoryCardMessageBox].
  final StoryCardLikeButton? likeButton;

  /// If non-null, the [forwardButton] is placed in right of
  /// the [StoryCardMessageBox].
  final StoryCardForwardButton? forwardButton;

  /// Creates a [StoryCardFooter] layout widget.
  /// The widget below this widget in the tree.
  /// This widget can only have one child. To lay out multiple children,
  /// let this widget's child be a widget such as Row, Column, or Stack,
  /// which have a children property, and then provide the children to
  /// that widget.
  final Widget? child;

  @override
  State<StoryCardFooter> createState() => _StoryCardFooterState();
}

class _StoryCardFooterState extends State<StoryCardFooter> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class StoryCardMessageBox extends StatefulWidget {
  const StoryCardMessageBox({
    super.key,
    this.color = Colors.white,
    this.borderRadius = const BorderRadius.all(Radius.circular(25)),
    this.borderWidth = 1.0,
    this.hintText = "SendMessage",
    this.fontSize = 14,
    this.onMessage,
    this.child,
  });

  /// The text [color] of the [StoryCardMessageBox].
  final Color color;

  /// If non-null, the corners of the [StoryCardMessageBox] are rounded by this.
  final BorderRadius borderRadius;

  /// Determines the width of the [StoryCardMessageBox] border.
  final double borderWidth;

  /// The [hintText] of the [StoryCardMessageBox].
  final String hintText;

  /// The [fontSize] of the [StoryCardMessageBox].
  final double fontSize;

  /// This callback is called when previous [StoryCard] is displayed.
  /// Returns a [StoryCardMessage] that includes the card index and message.
  final ValueChanged<StoryCardMessage>? onMessage;

  /// Creates a layout widget on the [StoryCard] when the [StoryCardMessageBox].
  /// opens message box. a overlay widget placed in the [child].
  /// The widget below this widget in the tree.
  /// This widget can only have one child. To lay out multiple children,
  /// let this widget's child be a widget such as Row, Column, or Stack,
  /// which have a children property, and then provide the children to
  /// that widget.
  final Widget? child;

  @override
  State<StoryCardMessageBox> createState() => _StoryCardMessageBoxState();
}

class _StoryCardMessageBoxState extends State<StoryCardMessageBox> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class StoryCardLikeButton extends StatefulWidget {
  const StoryCardLikeButton({
    super.key,
    this.color = Colors.white,
    this.icon,
    this.iconSize = 28,
    this.onLike,
  });

  /// The [color] of the [StoryCardLikeButton].
  final Color color;

  /// A Icon Widget that is placed in right of the [StoryCardMessageBox].
  /// Gets a IconData.
  final IconData? icon;

  /// The [iconSize] of the [StoryCardLikeButton].
  final double iconSize;

  /// This callback is called when previous [StoryCard] is displayed.
  /// Returns a [StoryCardLike] that includes the card index and liked.
  final ValueChanged<StoryCardLike>? onLike;

  @override
  State<StoryCardLikeButton> createState() => _StoryCardLikeButtonState();
}

class _StoryCardLikeButtonState extends State<StoryCardLikeButton> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class StoryCardForwardButton extends StatefulWidget {
  const StoryCardForwardButton({
    super.key,
    this.color = Colors.white,
    this.icon = CupertinoIcons.arrowshape_turn_up_right,
    this.iconSize = 28,
    this.onForward,
    this.child,
  });

  /// The [color] of the [StoryCardForwardButton].
  final Color color;

  /// A Icon Widget that is placed in right of the [StoryCardMessageBox].
  /// Gets a IconData.
  final IconData icon;

  /// The [iconSize] of the [StoryCardForwardButton].
  final double iconSize;

  /// This callback is called when previous [StoryCard] is displayed.
  /// Returns a card index of the [StoryCard] list.
  final ValueChanged<int>? onForward;

  /// Creates a layout widget on the [StoryCard].
  /// The widget below this widget in the tree.
  /// This widget can only have one child. To lay out multiple children,
  /// let this widget's child be a widget such as Row, Column, or Stack,
  /// which have a children property, and then provide the children to
  /// that widget.
  final Widget? child;

  @override
  State<StoryCardForwardButton> createState() => _StoryCardForwardButtonState();
}

class _StoryCardForwardButtonState extends State<StoryCardForwardButton> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class StoryCardMessage {
  const StoryCardMessage({
    required this.cardIndex,
    required this.message,
  });

  /// The [cardIndex] of the [StoryCard] list.
  final int cardIndex;

  /// A message sent from [StoryCardMessageBox] Text.
  final String message;
}

class StoryCardLike {
  const StoryCardLike({
    required this.cardIndex,
    required this.liked,
  });

  /// The [cardIndex] of the [StoryCard] list.
  final int cardIndex;

  /// Determines a boolean value that [StoryCardLikeButton] is liked.
  final bool liked;
}

/// It can be used to control the state of [Story].
class StoryController extends ValueNotifier<dynamic> {
  _StoryState? _storyState;

  StoryController() : super(dynamic);

  void _addState(_StoryState storyState) {
    _storyState = storyState;
  }

  /// Determine if the [Story.controller] is attached to an instance of the
  /// [Story] (this property must be true before any other [StoryController]
  /// functions can be used).
  bool get isAttached => _storyState != null;

  /// Closes the [Story].
  void closeStory() async {
    assert(isAttached, "StoryController must be attached to a Story");
    return _storyState!._closeStory();
  }

  /// Opens the [Story].
  /// If the [cardIndex] null, default [cardIndex] is not [StoryCard.visited].
  Future<void> openStory(
    BuildContext context, {
    int storyIndex = 0,
    int? cardIndex,
  }) async {
    assert(isAttached, "StoryController must be attached to a Story");
    return _storyState!._openStory(context, storyIndex, cardIndex);
  }

  /// Opens the [Story] by [StoryUser.userId].
  /// If the [cardIndex] null, default [cardIndex] is not [StoryCard.visited].
  Future<void> openStoryByUserId(
    BuildContext context, {
    int userId = 0,
    int? cardIndex,
  }) async {
    assert(isAttached, "StoryController must be attached to a Story");
    return _storyState!._openStoryByUserId(context, userId, cardIndex);
  }

  /// Sets a value for the [StoryCard.visited].
  Future<void> setStoryCardVisited({
    required int storyIndex,
    required int cardIndex,
    required bool visited,
  }) async {
    assert(isAttached, "StoryController must be attached to a Story");
    return _storyState!._setStoryCardVisited(storyIndex, cardIndex, visited);
  }

  /// Sets a value for the [StoryCard.visited] by [StoryUser.userId].
  Future<void> setStoryCardVisitedByUserId({
    required int userId,
    required int cardIndex,
    required bool visited,
  }) async {
    assert(isAttached, "StoryController must be attached to a Story");
    return _storyState!
        ._setStoryCardVisitedByUserId(userId, cardIndex, visited);
  }

  /// Plays the [Story].
  void playStory() async {
    assert(isAttached, "StoryController must be attached to a Story");
    return _storyState!._playStory();
  }

  /// Pauses the [Story].
  void pauseStory() async {
    assert(isAttached, "StoryController must be attached to a Story");
    return _storyState!._pauseStory();
  }

  /// Sets a function to [_StoryState._autoplayNotifier].
  set _autoplayNotifier(void Function(bool) fn) =>
      _storyState!._autoplayNotifier = fn;

  /// Returns whether or not the [Story] is Autoplay.
  bool get isAutoplay {
    assert(isAttached, "StoryController must be attached to a Story");
    return _storyState!._autoplay;
  }
}

/// /////////////////////////////////////////////// ///
///                                                 ///
///         [Story] related private classes         ///
///                                                 ///
/// /////////////////////////////////////////////// ///

/// extensions to change style of the [StoryUser.label] Text widget.
extension _TextExtention on Text {
  Text get _toEllipsis => Text(data!,
      key: key,
      style: style,
      strutStyle: strutStyle,
      textAlign: textAlign,
      textDirection: textDirection,
      locale: locale,
      softWrap: softWrap,
      overflow: TextOverflow.ellipsis,
      textScaler: textScaler,
      maxLines: maxLines,
      semanticsLabel: semanticsLabel,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
      selectionColor: selectionColor);
  Text get _toCenter => Text(data!,
      key: key,
      style: style,
      strutStyle: strutStyle,
      textAlign: TextAlign.center,
      textDirection: textDirection,
      locale: locale,
      softWrap: softWrap,
      overflow: overflow,
      textScaler: textScaler,
      maxLines: maxLines,
      semanticsLabel: semanticsLabel,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
      selectionColor: selectionColor);
  Text get _toOneLine => Text(data!,
      key: key,
      style: style,
      strutStyle: strutStyle,
      textAlign: textAlign,
      textDirection: textDirection,
      locale: locale,
      softWrap: softWrap,
      overflow: overflow,
      textScaler: textScaler,
      maxLines: 1,
      semanticsLabel: semanticsLabel,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
      selectionColor: selectionColor);
  Text get _toCardLabel => Text(
        data!,
        key: key,
        style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
            overflow: TextOverflow.ellipsis),
      );
}

/// A modal route that replaces the entire screen with a [_Storyboard]
/// layout widget.
class _StoryPageRoute extends PageRouteBuilder {
  _StoryPageRoute({
    required this.startPosition,
    this.duration = const Duration(milliseconds: 200),
    this.reverseDuration = const Duration(milliseconds: 200),
    this.animationCurve = Curves.easeOut,
    this.backgroundColor,
    required this.page,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            animation =
                CurvedAnimation(parent: animation, curve: animationCurve);
            return Scaffold(
              resizeToAvoidBottomInset: false,
              backgroundColor: backgroundColor,
              body: SlideTransition(
                position: Tween<Offset>(
                  begin: startPosition,
                  end: Offset.zero,
                ).animate(animation),
                child: ScaleTransition(
                  scale: animation,
                  alignment: Alignment.topLeft,
                  child: child,
                ),
              ),
            );
          },
          transitionDuration: duration,
          reverseTransitionDuration: reverseDuration,
          fullscreenDialog: true,
        );

  /// The [startPosition] of the [_StoryPageRoute].
  final Offset startPosition;

  /// The [duration] of the [_StoryPageRoute].
  final Duration duration;

  /// The [reverseDuration] of the [_StoryPageRoute].
  final Duration reverseDuration;

  /// The [animationCurve] of the [_StoryPageRoute].
  final Curve animationCurve;

  /// The [backgroundColor] of the [_StoryPageRoute].
  final Color? backgroundColor;

  /// The [page] of the [_StoryPageRoute].
  /// Creates a layout widget.
  final Widget page;
}

class _Storyboard extends StatefulWidget {
  const _Storyboard({
    super.key,
    this.storyController,
    required this.autoplay,
    required this.storyIndex,
    this.cardIndex,
    this.allCardVisited,
    required this.children,
  }) : assert(0 <= storyIndex && storyIndex < children.length);

  /// It can be used to control the state of [Story].
  final StoryController? storyController;

  /// The [autoplay] of the [StoryUser] whether or not the [Story.autoplay]
  /// is Autoplay.
  final bool autoplay;

  /// The [storyIndex] of the [StoryUser] list.
  final int storyIndex;

  /// The [cardIndex] of the [StoryCard] list.
  final int? cardIndex;

  /// The [allCardVisited] of the [StoryCard.visited].
  final bool? allCardVisited;

  /// Creates a [StoryUser] layout widget.
  final List<StoryUser> children;

  @override
  State<_Storyboard> createState() => _StoryboardState();
}

class _StoryboardState extends State<_Storyboard>
    with TickerProviderStateMixin {
  PageController? _pageController;
  int _storyIndex = 0;
  int _currentStoryIndex = 0;
  int _cardIndex = 0;
  bool _isDrag = false;
  ValueChanged<bool>? _isDragNotifier;
  VoidCallback? _isDragUp;
  ValueChanged<int?>? _cardIndexNotifier;
  final _CardController _cardController = _CardController();
  List<Widget> _children = [];
  AnimationController? _progressController;
  _StoryCardTimer? _storyCardTimer;
  bool _isCallDragNotifier = false;
  bool _isTapped = false;
  bool _autoplay = true;

  @override
  void initState() {
    super.initState();
    _cardController._addState(this);
    _autoplay = widget.autoplay;
    _storyIndex = widget.storyIndex;
    _setUnvisitedToAllVisitedStories();
    _progressController = AnimationController(
      duration: Duration.zero,
      vsync: this,
    );
    _storyCardTimer = _StoryCardTimer();
    _pageController = PageController(initialPage: _storyIndex + 1);
    _pageController?.addListener(() {
      setState(() {
        _storyIndex = (_pageController!.page!.toInt() - 1);
        _isDrag = !(_storyIndex.toDouble() == _pageController!.page! - 1.0);
      });

      /// Begin Drag
      if (_isDrag && !_isCallDragNotifier) {
        _pauseStory();
        if (_storyIndex < widget.children.length) {
          int pauseStoryIndex = _storyIndex < _currentStoryIndex
              ? _currentStoryIndex
              : (_storyIndex >= 0 ? _storyIndex : 0);
          int pauseCartIndex =
              _getLastVisitedCardIndex(storyIndex: pauseStoryIndex);
          widget.children[pauseStoryIndex].children[pauseCartIndex].onPause
              ?.call(pauseCartIndex);
        }
        _cardIndexNotifier?.call(null);
        _isDragNotifier?.call(true);
        _isCallDragNotifier = true;
      }

      /// End Drag
      if (!_isDrag) {
        if (_storyIndex < widget.children.length) {
          int resumeCartIndex =
              _getLastVisitedCardIndex(storyIndex: _storyIndex);
          widget.children[_storyIndex].children[resumeCartIndex].onResume
              ?.call(resumeCartIndex);
        }
        _currentStoryIndex = _storyIndex;
        _children = _getCardList();
        _playStory(isCallVisit: true);
        _isTapped = false;
        _isDragNotifier?.call(false);
        _isCallDragNotifier = false;
      }
    });
    _children = _getCardList();
    _playStory(isCallVisit: true);
    widget.storyController?._autoplayNotifier = (autoplay) {
      if (mounted) {
        setState(() {
          _autoplay = autoplay;
        });
      }
      widget.storyController!.isAutoplay
          ? _playStory(isCallVisit: true)
          : _pauseStory();
    };
  }

  @override
  void dispose() {
    _pageController?.dispose();
    _progressController?.stop();
    _progressController?.dispose();
    _storyCardTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    assert(widget.children[widget.storyIndex].children.isNotEmpty);
    return SafeArea(
      child: Builder(builder: (context) {
        return GestureDetector(
          onVerticalDragEnd: (DragEndDetails details) =>
              _onVerticalDragEnd(details.velocity),
          child: PageView.builder(
            physics: _isTapped && _isDrag
                ? const NeverScrollableScrollPhysics()
                : const BouncingScrollPhysics(),
            onPageChanged: (index) {
              _progressController?.reset();
              if (index == 0) {
                _pageController?.animateToPage(1,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.ease);
              }
              if (index == _children.length - 1) Navigator.pop(context);
            },
            controller: _pageController,
            itemCount: _children.length,
            itemBuilder: (context, index) {
              double value;
              if (_pageController?.position.haveDimensions == false) {
                value = index.toDouble();
              } else {
                value = _pageController!.page!;
              }
              return _SwipeWidget(
                index: index,
                page: value,
                child: _children[index],
              );
            },
          ),
        );
      }),
    );
  }

  /// handles when vertical drag.
  void _onVerticalDragEnd(Velocity v) {
    try {
      if (v.pixelsPerSecond.direction > 0.0) {
        Navigator.pop(context);
      } else if (v.pixelsPerSecond.direction < 0.0) {
        _isDragUp?.call();
      }
    } catch (e) {
      return;
    }
  }

  /// Pauses the [Story].
  void _pauseStory() {
    try {
      _storyCardTimer?.cancel();
      _progressController?.stop();
    } catch (e) {
      return;
    }
  }

  /// Plays the [Story].
  void _playStory({required bool isCallVisit}) {
    _pauseStory();
    if (_isDrag) return;
    try {
      _cardIndex = _getLastVisitedCardIndex(storyIndex: _storyIndex);
      _cardIndexNotifier?.call(_cardIndex);
      List<StoryCard> cards = widget.children[_storyIndex].children;
      if (cards.isEmpty) return;
      if (isCallVisit) {
        WidgetsBinding.instance.addPostFrameCallback(
            (_) => cards[_cardIndex].onVisited?.call(_cardIndex));
      }
      if (_autoplay) {
        double timeLeft = cards[_cardIndex].cardDuration.inMilliseconds -
            (_progressController!.value *
                cards[_cardIndex].cardDuration.inMilliseconds);
        Duration cardDuration = Duration(milliseconds: timeLeft.toInt());
        _storyCardTimer
            ?.repeat(period: Timer.periodic(cardDuration, (_) => _nextStory()))
            .then((_) => _progressController?.repeat(
                period: cards[_cardIndex].cardDuration));
      }
    } catch (e) {
      return;
    }
  }

  /// Moves to previous of the [StoryUser].
  void _previousStory() {
    List<StoryCard> cards = widget.children[_storyIndex].children;
    _progressController?.reset();
    cards[_cardIndex].onDispose?.call(_cardIndex);
    if (_cardIndex > 0) {
      if (cards.where((e) => e.visited).length == cards.length) {
        _setStoryCardVisited(_storyIndex, _cardIndex, false);
      }
      _setStoryCardVisited(_storyIndex, _cardIndex - 1, false);
      _playStory(isCallVisit: true);
      cards[_cardIndex].onPrevious?.call(_cardIndex);
    } else {
      _pageController
          ?.previousPage(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut)
          .then((_) {
        widget.children[_storyIndex].children[_cardIndex].onPrevious
            ?.call(_cardIndex);
      });
    }
  }

  /// Moves to next of the [StoryUser].
  void _nextStory() {
    List<StoryCard> cards = widget.children[_storyIndex].children;
    if (_cardIndex >= cards.length) return;
    _progressController?.reset();
    cards[_cardIndex].onDispose?.call(_cardIndex);
    if (_cardIndex < cards.length - 1) {
      _setStoryCardVisited(_storyIndex, _cardIndex, true);
      _playStory(isCallVisit: true);
      _isTapped = false;
      cards[_cardIndex].onNext?.call(_cardIndex);
    } else {
      _pageController
          ?.nextPage(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut)
          .then((_) => cards[_cardIndex].onNext?.call(_cardIndex));
    }
  }

  /// Moves to previous of the [StoryCard].
  void _previousCard() {
    if ((_isTapped && _isDrag) || (_storyIndex == 0 && _cardIndex == 0)) return;
    _isTapped = true;
    _pauseStory();
    _previousStory();
  }

  /// Moves to next of the [StoryCard].
  void _nextCard() {
    if (_isTapped && _isDrag) return;
    _isTapped = true;
    _pauseStory();
    _nextStory();
  }

  /// Gets a list of [_CardList].
  List<Widget> _getCardList() {
    List<Widget> cardList = [Container()];
    for (int i = 0; i < widget.children.length; i++) {
      cardList.add(_CardList(
        cardController: _cardController,
        avatar: widget.children[i].avatar,
        label: widget.children[i].label,
        cards: widget.children[i].children,
        progressController: _progressController!,
        storyIndex: i,
        cardIndex: _getLastVisitedCardIndex(storyIndex: i),
      ));
    }
    cardList.add(Container());
    return cardList;
  }

  /// Gets last [_cardIndex] that visited.
  int _getLastVisitedCardIndex({required int storyIndex}) {
    if (storyIndex == widget.children.length) return 0;
    int lastVisitedCardIndex = 0;
    List<StoryCard> cards = widget.children[storyIndex].children;
    if (cards.where((e) => e.visited).length == cards.length) {
      lastVisitedCardIndex = cards.length - 1;
    } else {
      for (int i = 0; i < cards.length; i++) {
        if (cards[i].visited) {
          lastVisitedCardIndex = (i == cards.length - 1) ? 0 : i + 1;
        }
      }
    }
    return lastVisitedCardIndex;
  }

  /// If all [StoryCard] is visited, sets all to false.
  List<StoryUser> _setUnvisitedToAllVisitedStories() {
    if (widget.allCardVisited != null && widget.allCardVisited!) {
      for (int i = 0; i < widget.children.length; i++) {
        for (int j = 0; j < widget.children[i].children.length; j++) {
          _setStoryCardVisited(i, j, false);
        }
      }
    }
    return widget.children;
  }

  /// Sets the [StoryCard.visited].
  Future<void> _setStoryCardVisited(
      int storyIndex, int cardIndex, bool visited) async {
    assert(storyIndex >= 0 && storyIndex < widget.children.length);
    assert(cardIndex >= 0 &&
        cardIndex < widget.children[storyIndex].children.length);
    StoryCard c = widget.children[storyIndex].children[cardIndex];
    widget.children[storyIndex].children[cardIndex] = StoryCard(
      key: c.key,
      visited: visited,
      cardDuration: c.cardDuration,
      color: c.color,
      borderRadius: c.borderRadius,
      onVisited: c.onVisited,
      onDispose: c.onDispose,
      onPause: c.onPause,
      onResume: c.onResume,
      onNext: c.onNext,
      onPrevious: c.onPrevious,
      footer: c.footer,
      childOverlay: c.childOverlay,
      child: c.child,
    );
  }
}

class _CardList extends StatefulWidget {
  const _CardList({
    required this.cardController,
    this.avatar,
    this.label,
    required this.cards,
    required this.progressController,
    required this.storyIndex,
    required this.cardIndex,
  });

  /// It can be used to control the state of [StoryCard].
  final _CardController cardController;

  /// The [avatar] of the [StoryUser].
  /// A Widget that is placed in the [StoryUser.avatar].
  final Widget? avatar;

  /// The [label] of the [StoryCard] tabBar label.
  final Text? label;

  /// Creates a [StoryCard] layout widget.
  final List<StoryCard> cards;

  /// It can be used to control the animation of [StoryCard] progress bar.
  final AnimationController progressController;

  /// The [storyIndex] of the [StoryUser] list.
  final int storyIndex;

  /// The [cardIndex] of the [StoryCard] list.
  final int cardIndex;

  @override
  State<_CardList> createState() => _CardListState();
}

class _CardListState extends State<_CardList>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  double _screenWidth = 0.0, _screenHeight = 0.0;
  int _cardIndex = 0;
  bool _isPauseStory = false;
  bool _isLike = false;
  final TextEditingController sendMessageController = TextEditingController();
  AnimationController? _animationController;
  final FocusNode sendMessageFocusNode = FocusNode();
  final GlobalKey _storyCardOpacityScreenKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _cardIndex = widget.cardIndex;
    widget.cardController.isDragNotifier = (isDrag) {
      if (!isDrag) {
        sendMessageController.text = "";
        widget.cardController.cardIndex(null, isPauseStory: false);
      }
      if (_storyCardOpacityScreenKey.currentContext != null) {
        Navigator.pop(_storyCardOpacityScreenKey.currentContext!);
      }
    };
    widget.cardController.isDragUp = () {
      if (widget.cards[_cardIndex].footer?.messageBox != null)
        showSendMessage();
    };
    widget.cardController.cardIndexNotifier = (cardIndex) {
      _isLike = false;
      widget.cardController.cardIndex(cardIndex);
    };
    sendMessageFocusNode.addListener(() {
      if (!sendMessageFocusNode.hasFocus) {
        hideSendMessage();
        if (_storyCardOpacityScreenKey.currentContext != null) {
          Navigator.pop(_storyCardOpacityScreenKey.currentContext!);
        }
      }
    });
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      value: 1.0,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _animationController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      hideSendMessage();
      hideForwardChild();
      if (_storyCardOpacityScreenKey.currentContext != null) {
        Navigator.pop(_storyCardOpacityScreenKey.currentContext!);
      }
    } else if (state == AppLifecycleState.inactive) {
      widget.cardController.pauseStory();
    }
  }

  /// Hides the [StoryCardMessageBox].
  void hideSendMessage() {
    widget.cards[_cardIndex].onResume?.call(_cardIndex);
    widget.cardController.playStory(isCallVisit: false);
  }

  /// Shows the [StoryCardMessageBox].
  void showSendMessage() {
    widget.cards[_cardIndex].onPause?.call(_cardIndex);
    widget.cardController.pauseStory();
    Navigator.push(
        context,
        PageRouteBuilder(
            opaque: false,
            transitionDuration: const Duration(milliseconds: 0),
            reverseTransitionDuration: const Duration(milliseconds: 0),
            pageBuilder: (_, __, ___) => _StoryCardOpacityScreen(
                  key: _storyCardOpacityScreenKey,
                  color: Colors.black.withAlpha(180),
                  margin: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: Stack(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 50),
                        child:
                            widget.cards[_cardIndex].footer?.messageBox?.child,
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(15, 0, 7, 0),
                          decoration: BoxDecoration(
                              borderRadius: widget.cards[_cardIndex].footer
                                  ?.messageBox?.borderRadius,
                              border: Border.all(
                                  color: widget.cards[_cardIndex].footer!
                                      .messageBox!.color
                                      .withAlpha(100),
                                  width: 1)),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  autofocus: true,
                                  keyboardType: TextInputType.multiline,
                                  minLines: 1,
                                  maxLines: 5,
                                  controller: sendMessageController,
                                  focusNode: sendMessageFocusNode,
                                  cursorColor: widget.cards[_cardIndex].footer
                                      ?.messageBox?.color,
                                  style: TextStyle(
                                      fontSize: widget.cards[_cardIndex].footer
                                          ?.messageBox?.fontSize,
                                      color: widget.cards[_cardIndex].footer
                                          ?.messageBox?.color),
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: widget.cards[_cardIndex].footer
                                        ?.messageBox?.hintText,
                                    hintStyle: TextStyle(
                                        fontSize: widget.cards[_cardIndex]
                                            .footer?.messageBox?.fontSize,
                                        color: widget.cards[_cardIndex].footer
                                            ?.messageBox?.color),
                                  ),
                                  onTap: () {
                                    widget.cardController.pauseStory();
                                  },
                                ),
                              ),
                              MaterialButton(
                                minWidth: 50,
                                padding: EdgeInsets.zero,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: widget.cards[_cardIndex].footer!
                                      .messageBox!.borderRadius,
                                ),
                                onPressed: () {
                                  widget.cards[_cardIndex].footer?.messageBox
                                      ?.onMessage
                                      ?.call(StoryCardMessage(
                                          cardIndex: _cardIndex,
                                          message: sendMessageController.text
                                              .toString()
                                              .trim()));
                                  hideSendMessage();
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  "Send",
                                  style: TextStyle(
                                      color: widget.cards[_cardIndex].footer!
                                          .messageBox?.color,
                                      fontSize: widget.cards[_cardIndex].footer
                                          ?.messageBox?.fontSize),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ))).then((_) => hideSendMessage());
  }

  /// Hides the [_StoryCardOpacityScreen].
  void hideForwardChild() {
    widget.cards[_cardIndex].onResume?.call(_cardIndex);
    widget.cardController.playStory(isCallVisit: false);
  }

  /// Shows the [_StoryCardOpacityScreen].
  void showForwardChild() {
    widget.cards[_cardIndex].onPause?.call(_cardIndex);
    widget.cardController.pauseStory();
    Navigator.push(
        context,
        PageRouteBuilder(
            opaque: false,
            transitionDuration: const Duration(milliseconds: 0),
            reverseTransitionDuration: const Duration(milliseconds: 0),
            pageBuilder: (_, __, ___) => _StoryCardOpacityScreen(
                  key: _storyCardOpacityScreenKey,
                  color: Colors.transparent,
                  margin: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: widget.cards[_cardIndex].footer?.forwardButton?.child,
                ))).then((_) => hideForwardChild());
  }

  @override
  Widget build(BuildContext context) {
    _screenWidth = MediaQuery.of(context).size.width;
    _screenHeight = MediaQuery.of(context).size.height;
    if (widget.cards.isEmpty) return Container(color: const Color(0xFF333333));
    return ValueListenableBuilder<_CardValue>(
      valueListenable: widget.cardController,
      builder: (_, value, __) {
        if (widget.storyIndex == widget.cardController.storyIndex) {
          if (value.cardIndex != null &&
              value.cardIndex! < widget.cards.length) {
            _cardIndex = value.cardIndex!;
          }
          if (value.isPauseStory != null) _isPauseStory = value.isPauseStory!;
        }
        return Stack(
          alignment: AlignmentDirectional.bottomCenter,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 80),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: widget.cards[_cardIndex].color,
                borderRadius: widget.cards[_cardIndex].borderRadius,
              ),
              child: GestureDetector(
                child: Stack(
                  children: [
                    Container(child: widget.cards[_cardIndex].child),
                    Container(
                      margin: EdgeInsets.zero,
                      width: _screenWidth * 0.3,
                      height: _screenHeight,
                      child: GestureDetector(
                        onTapDown: (_) {
                          widget.cardController.pauseStory();
                        },
                        onTapUp: (_) {
                          widget.cardController.previousCard();
                        },
                        onLongPressStart: (_) {
                          setState(() {
                            _isPauseStory = true;
                          });
                          widget.cardController.pauseStory();
                          widget.cards[_cardIndex].onPause?.call(_cardIndex);
                        },
                        onLongPressEnd: (_) {
                          setState(() {
                            _isPauseStory = false;
                          });
                          widget.cards[_cardIndex].onResume?.call(_cardIndex);
                          widget.cardController.playStory(isCallVisit: false);
                        },
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: _screenWidth * 0.3),
                      width: _screenWidth * 0.7,
                      height: _screenHeight,
                      child: GestureDetector(
                        onTapDown: (_) {
                          widget.cardController.pauseStory();
                        },
                        onTapUp: (_) {
                          widget.cardController.nextCard();
                        },
                        onLongPressStart: (_) {
                          setState(() {
                            _isPauseStory = true;
                          });
                          widget.cardController.pauseStory();
                          widget.cards[_cardIndex].onPause?.call(_cardIndex);
                        },
                        onLongPressEnd: (_) {
                          setState(() {
                            _isPauseStory = false;
                          });
                          widget.cards[_cardIndex].onResume?.call(_cardIndex);
                          widget.cardController.playStory(isCallVisit: false);
                        },
                      ),
                    ),
                    Container(
                      child: widget.cards[_cardIndex].childOverlay,
                    ),
                    AnimatedOpacity(
                      opacity: _isPauseStory ? 0.0 : 1.0,
                      duration: const Duration(milliseconds: 150),
                      child: _cardTabBar(),
                    ),
                  ],
                ),
              ),
            ),
            if (widget.cards[_cardIndex].footer != null)
              Container(
                padding: const EdgeInsets.fromLTRB(7, 20, 7, 22),
                child: AnimatedOpacity(
                  opacity: _isPauseStory ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 150),
                  child: Row(
                    children: [
                      Expanded(
                        child: widget.cards[_cardIndex].footer?.messageBox !=
                                null
                            ? GestureDetector(
                                onTap: () {
                                  showSendMessage();
                                },
                                child: Container(
                                    padding: const EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                        borderRadius: widget.cards[_cardIndex]
                                            .footer?.messageBox?.borderRadius,
                                        border: Border.all(
                                            color: widget.cards[_cardIndex]
                                                .footer!.messageBox!.color
                                                .withAlpha(100),
                                            width: widget
                                                .cards[_cardIndex]
                                                .footer!
                                                .messageBox!
                                                .borderWidth)),
                                    child: Text(
                                      widget.cards[_cardIndex].footer!
                                          .messageBox!.hintText,
                                      style: TextStyle(
                                          color: widget.cards[_cardIndex].footer
                                              ?.messageBox?.color,
                                          fontSize: widget.cards[_cardIndex]
                                              .footer?.messageBox?.fontSize),
                                    )),
                              )
                            : Container(
                                child: widget.cards[_cardIndex].footer?.child,
                              ),
                      ),
                      if (widget.cards[_cardIndex].footer?.likeButton != null)
                        IconButton(
                            padding: EdgeInsets.zero,
                            splashRadius: 22,
                            color: widget
                                .cards[_cardIndex].footer?.likeButton?.color,
                            iconSize: widget
                                .cards[_cardIndex].footer?.likeButton?.iconSize,
                            icon: ScaleTransition(
                              scale: Tween(begin: 0.7, end: 1.0).animate(
                                  CurvedAnimation(
                                      parent: _animationController!,
                                      curve: const Cubic(0.7, 0, 0.28, 2.0))),
                              child: Icon(
                                widget.cards[_cardIndex].footer?.likeButton
                                        ?.icon ??
                                    (_isLike
                                        ? CupertinoIcons.heart_fill
                                        : CupertinoIcons.heart),
                                color: _isLike
                                    ? Colors.red
                                    : widget.cards[_cardIndex].footer
                                        ?.likeButton?.color,
                              ),
                            ),
                            onPressed: () {
                              if (mounted) {
                                setState(() {
                                  _isLike = !_isLike;
                                });
                              }
                              _animationController?.reverse().then(
                                  (value) => _animationController?.forward());
                              widget
                                  .cards[_cardIndex].footer?.likeButton?.onLike
                                  ?.call(StoryCardLike(
                                      cardIndex: _cardIndex, liked: _isLike));
                            }),
                      if (widget.cards[_cardIndex].footer?.forwardButton !=
                          null)
                        IconButton(
                          padding: EdgeInsets.zero,
                          splashRadius: 22,
                          iconSize: widget.cards[_cardIndex].footer
                              ?.forwardButton?.iconSize,
                          icon: Icon(
                            widget
                                .cards[_cardIndex].footer?.forwardButton?.icon,
                            color: widget
                                .cards[_cardIndex].footer?.forwardButton?.color,
                          ),
                          onPressed: () {
                            showForwardChild();
                            widget.cards[_cardIndex].footer?.forwardButton
                                ?.onForward
                                ?.call(_cardIndex);
                          },
                        ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _cardTabBar() {
    List<Widget> tabs = [];
    for (int i = 0; i < widget.cards.length; i++) {
      tabs.add(Container(
        width: (_screenWidth - 10) / widget.cards.length,
        height: widget.cards[_cardIndex].progressBarHeight,
        padding: const EdgeInsets.all(1.2),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
              color:
                  i < _cardIndex ? Colors.white : Colors.white.withAlpha(180),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(40),
                  spreadRadius: 0,
                  blurRadius: 3,
                  offset: const Offset(0, 0),
                )
              ],
              borderRadius: BorderRadius.all(
                  Radius.circular(widget.cards[_cardIndex].progressBarHeight))),
          child: i == _cardIndex &&
                  widget.storyIndex == widget.cardController.storyIndex
              ? AnimatedBuilder(
                  animation: widget.progressController,
                  builder: (context, child) {
                    return LinearProgressIndicator(
                      value: widget.progressController.value,
                      backgroundColor: Colors.transparent,
                      color: Colors.white,
                    );
                  })
              : null,
        ),
      ));
    }

    return Stack(
      children: [
        Container(
          width: _screenWidth,
          height: 100,
          decoration: BoxDecoration(
              gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withAlpha(50),
              Colors.transparent,
            ],
          )),
        ),
        Container(
          margin: const EdgeInsets.fromLTRB(5, 10, 5, 10),
          child: Row(
            children: tabs,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 22, left: 12),
          child: Row(
            children: [
              if (widget.avatar != null)
                Container(
                  width: 36,
                  height: 36,
                  margin: const EdgeInsets.only(right: 10),
                  clipBehavior: Clip.antiAlias,
                  decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(18))),
                  child: widget.avatar,
                ),
              if (widget.label != null)
                Container(child: widget.label!._toCardLabel),
            ],
          ),
        ),
      ],
    );
  }
}

class _StoryCardOpacityScreen extends StatefulWidget {
  const _StoryCardOpacityScreen({
    super.key,
    required this.margin,
    required this.color,
    this.child,
  });

  /// The [margin] of the [_StoryCardOpacityScreen]
  final EdgeInsets margin;

  /// The [color] of the [_StoryCardOpacityScreen]
  final Color color;

  /// Creates a layout widget on the [_StoryCardOpacityScreen].
  /// The widget below this widget in the tree.
  /// This widget can only have one child. To lay out multiple children,
  /// let this widget's child be a widget such as Row, Column, or Stack,
  /// which have a children property, and then provide the children to
  /// that widget.
  final Widget? child;

  @override
  State<_StoryCardOpacityScreen> createState() =>
      _StoryCardOpacityScreenState();
}

class _StoryCardOpacityScreenState extends State<_StoryCardOpacityScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        color: widget.color,
        child: Stack(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              onVerticalDragEnd: (_) {
                Navigator.pop(context);
              },
              onHorizontalDragEnd: (_) {
                Navigator.pop(context);
              },
            ),
            Container(margin: widget.margin, child: widget.child),
          ],
        ),
      ),
    );
  }
}

/// It's used to control the [StoryCard] time.
class _StoryCardTimer {
  _StoryCardTimer();

  Timer? _timer;

  /// Repeats the [_timer].
  Future<void> repeat({required Timer period}) async {
    _timer = period;
  }

  /// Cancels the [_timer].
  Future<void> cancel() async {
    _timer?.cancel();
  }
}

/// Sets a value for the state of [StoryCard].
class _CardValue {
  const _CardValue({this.cardIndex, this.isPauseStory});

  final int? cardIndex;
  final bool? isPauseStory;

  /// Sets card index of the [StoryCard].
  factory _CardValue.cardIndex(int? cardIndex, {bool? isPauseStory}) {
    return _CardValue(cardIndex: cardIndex, isPauseStory: isPauseStory);
  }
}

/// It is used to control the state of [StoryCard].
class _CardController extends ValueNotifier<_CardValue> {
  _CardController() : super(const _CardValue());

  _StoryboardState? _storyboardState;

  /// adds a [_storyboardState] for the [_CardController].
  void _addState(_StoryboardState storyboardState) {
    _storyboardState = storyboardState;
  }

  /// Sets card index of the [StoryCard].
  Future<void> cardIndex(int? cardIndex, {bool? isPauseStory}) async {
    value = _CardValue.cardIndex(cardIndex, isPauseStory: isPauseStory);
  }

  /// Moves to previous of the [StoryCard].
  Future<void> previousCard() async {
    return _storyboardState?._previousCard();
  }

  /// Moves to next of the [StoryCard].
  Future<void> nextCard() async {
    return _storyboardState?._nextCard();
  }

  /// Pauses the [Story].
  Future<void> pauseStory() async {
    return _storyboardState?._pauseStory();
  }

  /// Plays the [Story].
  Future<void> playStory({required bool isCallVisit}) async {
    return _storyboardState?._playStory(isCallVisit: isCallVisit);
  }

  /// Sets a function to [_StoryboardState._isDragNotifier].
  set isDragNotifier(void Function(bool) fn) =>
      _storyboardState!._isDragNotifier = fn;

  /// Sets a function to [_StoryboardState._isDragUp].
  set isDragUp(void Function() fn) => _storyboardState!._isDragUp = fn;

  /// Sets a function to [_StoryboardState._cardIndexNotifier].
  set cardIndexNotifier(void Function(int?) fn) =>
      _storyboardState!._cardIndexNotifier = fn;

  /// Returns whether or not the [_Storyboard] is Dragged.
  bool get isDrag => _storyboardState!._isDrag;

  /// Returns a story index of the [Story] list.
  int get storyIndex => _storyboardState!._storyIndex;
}

class _SwipeWidget extends StatefulWidget {
  const _SwipeWidget({
    required this.index,
    required this.page,
    required this.child,
  });

  /// The story [index] of the [Story] list.
  final int index;

  /// Gets [page] value to handle PageView of the [_Storyboard] story index.
  final double page;

  /// Creates a [_CardList] layout widget.
  /// The widget below this widget in the tree.
  /// This widget can only have one child. To lay out multiple children,
  /// let this widget's child be a widget such as Row, Column, or Stack,
  /// which have a children property, and then provide the children to
  /// that widget.
  final Widget child;

  @override
  State<_SwipeWidget> createState() => _SwipeWidgetState();
}

class _SwipeWidgetState extends State<_SwipeWidget> {
  /// Displays the [StoryCard] as a cube.
  @override
  Widget build(BuildContext context) {
    final isLeaving = (widget.index - widget.page) <= 0;
    final t = (widget.index - widget.page);
    final rotationY = lerpDouble(0, 90, t);
    final transform = Matrix4.identity();
    transform.setEntry(3, 2, 0.0015);
    transform.rotateY(-(rotationY! * (pi / 180.0)));
    return Transform(
      alignment: isLeaving ? Alignment.centerRight : Alignment.centerLeft,
      transform: transform,
      child: Stack(
        children: [
          widget.child,
        ],
      ),
    );
  }
}
