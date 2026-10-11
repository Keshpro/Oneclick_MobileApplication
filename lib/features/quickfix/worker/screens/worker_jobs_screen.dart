import 'package:flutter/material.dart';

class WorkerJobsScreen extends StatefulWidget {
  const WorkerJobsScreen({super.key});

  @override
  State<WorkerJobsScreen> createState() =>
      _WorkerJobsScreenState();
}

class _WorkerJobsScreenState extends State<WorkerJobsScreen> {
  String selectedFilter = 'All';

  final List<Map<String, dynamic>> jobs = [
    {
      'customer': 'Kasun Perera',
      'service': 'Ceiling fan repair',
      'area': 'Bentota',
      'status': 'Accepted',
      'date': '11 Oct 2026',
    },
    {
      'customer': 'Nimali Silva',
      'service': 'Power outlet repair',
      'area': 'Aluthgama',
      'status': 'In Progress',
      'date': '10 Oct 2026',
    },
    {
      'customer': 'Amal Fernando',
      'service': 'Light installation',
      'area': 'Bentota',
      'status': 'Completed',
      'date': '09 Oct 2026',
    },
  ];

  List<Map<String, dynamic>> get filteredJobs {
    if (selectedFilter == 'All') return jobs;

    return jobs
        .where((job) => job['status'] == selectedFilter)
        .toList();
  }

  void updateStatus(int index, String status) {
    final job = filteredJobs[index];

    setState(() {
      job['status'] = status;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Job marked as $status')),
    );
  }

  Color statusColor(String status) {
    switch (status) {
      case 'Completed':
        return Colors.green;
      case 'In Progress':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final visibleJobs = filteredJobs;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Jobs'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 8,
              children: [
                _filterButton('All'),
                _filterButton('Accepted'),
                _filterButton('In Progress'),
                _filterButton('Completed'),
              ],
            ),
          ),
          Expanded(
            child: visibleJobs.isEmpty
                ? const Center(child: Text('No jobs found.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: visibleJobs.length,
                    itemBuilder: (context, index) {
                      final job = visibleJobs[index];
                      final status = job['status'] as String;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const CircleAvatar(
                                    child: Icon(Icons.work_outline),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      job['service'] as String,
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Customer: ${job['customer']}',
                              ),
                              Text('Area: ${job['area']}'),
                              Text('Date: ${job['date']}'),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Text('Status: '),
                                  Chip(
                                    label: Text(status),
                                    backgroundColor:
                                        statusColor(status)
                                            .withAlpha(35),
                                    labelStyle: TextStyle(
                                      color: statusColor(status),
                                    ),
                                  ),
                                ],
                              ),
                              if (status == 'Accepted')
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () => updateStatus(
                                      index,
                                      'In Progress',
                                    ),
                                    child: const Text(
                                      'Start Job',
                                    ),
                                  ),
                                ),
                              if (status == 'In Progress')
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: () => updateStatus(
                                      index,
                                      'Completed',
                                    ),
                                    icon: const Icon(
                                      Icons.check_circle,
                                    ),
                                    label: const Text(
                                      'Complete Job',
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _filterButton(String filter) {
    return ChoiceChip(
      label: Text(filter),
      selected: selectedFilter == filter,
      onSelected: (_) {
        setState(() {
          selectedFilter = filter;
        });
      },
    );
  }
}
