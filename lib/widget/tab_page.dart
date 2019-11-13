import 'package:flutter/material.dart';

class TabPage extends StatefulWidget {
  final List<Widget> tabs;

  final List<Widget> pages;

  final List<Widget> actions;

  TabPage({Key key, this.tabs, this.pages, this.actions}) : super(key: key);

  @override
  _TabPageState createState() => _TabPageState();
}

class _TabPageState extends State<TabPage> with SingleTickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: widget.tabs.length, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TabBar(
            isScrollable: true,
            controller: _tabController,
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.black,
            labelPadding: const EdgeInsets.all(8.0),
            indicatorSize: TabBarIndicatorSize.label,
            tabs: widget.tabs),
        centerTitle: true,
        actions: widget.actions,
      ),
      body: TabBarView(
        controller: _tabController,
        children: widget.pages,
      ),
    );
  }
}
