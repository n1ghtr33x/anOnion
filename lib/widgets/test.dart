import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<MainPage> {
  final ScrollController _scrollController = ScrollController();
  double _avatarScale = 1.0;
  double _avatarRadius = 50.0;
  double _textOffset = 0.0;
  Alignment _textAlignment = Alignment.center;
  String _scrollState = 'initial'; // 'initial', 'half', 'full'

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      double offset = _scrollController.offset;
      // Скролл вверх
      if (offset < 0) {
        setState(() {
          if (offset <= -200 && _scrollState != 'full') {
            _scrollState = 'full';
            _avatarScale = 2.5;
            _avatarRadius = 0.0;
            _textOffset = 20.0;
            _textAlignment = Alignment.bottomLeft;
          } else if (offset <= -50 && _scrollState == 'initial') {
            _scrollState = 'half';
            _avatarScale = 1.5;
            _avatarRadius = 0.0;
            _textOffset = 10.0;
            _textAlignment = Alignment.bottomLeft;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: NotificationListener<ScrollUpdateNotification>(
        onNotification: (notification) {
          double offset = _scrollController.offset;
          // Скролл вниз
          if (notification.scrollDelta! > 0 && _scrollState != 'initial') {
            setState(() {
              if (offset >= -50 && _scrollState == 'half') {
                _scrollState = 'initial';
                _avatarScale = 1.0;
                _avatarRadius = 50.0;
                _textOffset = 0.0;
                _textAlignment = Alignment.center;
              } else if (offset >= -200 && _scrollState == 'full') {
                _scrollState = 'half';
                _avatarScale = 1.5;
                _avatarRadius = 0.0;
                _textOffset = 10.0;
                _textAlignment = Alignment.bottomLeft;
              }
            });
          }
          return true;
        },
        child: CustomScrollView(
          controller: _scrollController,
          physics: CustomScrollPhysics(scrollState: _scrollState),
          slivers: [
            SliverAppBar(
              expandedHeight: 300.0,
              floating: false,
              pinned: true,
              stretch: false,
              backgroundColor: Colors.blueAccent,
              flexibleSpace: LayoutBuilder(
                builder: (context, constraints) {
                  return FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Аватарка
                        Center(
                          child: Transform.scale(
                            scale: _avatarScale,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                _avatarRadius,
                              ),
                              child: Image.network(
                                'https://picsum.photos/150', // Замените на URL аватарки
                                fit: BoxFit.cover,
                                width: 100.0 * _avatarScale,
                                height: 100.0 * _avatarScale,
                              ),
                            ),
                          ),
                        ),
                        // Текст
                        AnimatedContainer(
                          duration: Duration(milliseconds: 200),
                          padding: EdgeInsets.only(
                            bottom: 20.0 + _textOffset,
                            left: _textAlignment == Alignment.bottomLeft
                                ? 20.0
                                : 0.0,
                          ),
                          alignment: _textAlignment,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment:
                                _textAlignment == Alignment.bottomLeft
                                ? CrossAxisAlignment.start
                                : CrossAxisAlignment.center,
                            children: [
                              Text(
                                "Имя пользователя",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (_avatarScale < 2.5)
                                Text(
                                  "Онлайн",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14.0,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate([
                ListTile(title: Text('Профиль')),
                ListTile(title: Text('Настройки')),
                ListTile(title: Text('Уведомления')),
                ListTile(title: Text('Конфиденциальность')),
                for (int i = 0; i < 20; i++)
                  ListTile(title: Text('Элемент $i')),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

// Кастомная физика для управления скроллом
class CustomScrollPhysics extends ScrollPhysics {
  final String scrollState;

  CustomScrollPhysics({required this.scrollState, ScrollPhysics? parent})
    : super(parent: parent);

  @override
  CustomScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return CustomScrollPhysics(scrollState: scrollState, parent: ancestor);
  }

  @override
  double applyBoundaryConditions(ScrollMetrics position, double value) {
    // Фиксируем позицию в полуэкранном или полноэкранном режиме
    if (scrollState == 'half' && value > -50 && position.pixels <= -50) {
      return value - (-50); // Зафиксировать на offset = -50
    }
    if (scrollState == 'full' && value > -200 && position.pixels <= -200) {
      return value - (-200); // Зафиксировать на offset = -200
    }
    return 0.0;
  }

  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) {
    // Убираем инерцию возврата в зафиксированных состояниях
    if ((scrollState == 'half' || scrollState == 'full') && velocity > 0) {
      return null; // Блокируем инерцию при скролле вниз
    }
    return super.createBallisticSimulation(position, velocity);
  }
}
