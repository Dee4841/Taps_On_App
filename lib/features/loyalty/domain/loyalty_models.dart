class Milestone {
  final String description;
  final int requiredTaps;
  final int rewardPoints;

  const Milestone({
    required this.description,
    required this.requiredTaps,
    required this.rewardPoints,
  });
}

const List<Milestone> defaultMilestones = [
  Milestone(description: 'First Tap!', requiredTaps: 1, rewardPoints: 10),
  Milestone(description: '5 Taps', requiredTaps: 5, rewardPoints: 20),
  Milestone(description: '10 Taps', requiredTaps: 10, rewardPoints: 30),
  Milestone(description: '25 Taps', requiredTaps: 25, rewardPoints: 50),
];
