import UIKit
import CoreData
import ProcedureKit
import ProcedureKitMobile
import ProcedureKitNetwork

class EarthquakesTableViewController: UITableViewController {
	fileprivate struct Storyboard {
		static let ShowEarthQuake = "showEarthquake"
	}
	
    // MARK: Properties
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>?

	let procedureQueue = ProcedureQueue()

	override func awakeFromNib() {
		super.awakeFromNib()
		
		let procedure = LoadEarthquakeModel { context in
			// Now that we have a context, build our `FetchedResultsController`.
			DispatchQueue.main.async() {
				let request = NSFetchRequest<NSFetchRequestResult>(entityName: Earthquake.entityName)
				request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)]
				request.fetchLimit = 100
				
				let controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
				self.fetchedResultsController = controller
				
				self.updateUI()
			}
		}
		procedureQueue.add(operation: procedure)
	}
	
	// MARK: View Controller
	
	@IBOutlet weak var refresh: UIRefreshControl!
	
	@IBAction func startRefreshing() {
		getEarthquakes()
	}

	override func numberOfSections(in tableView: UITableView) -> Int {
		return fetchedResultsController?.sections?.count ?? 0
	}

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let section = fetchedResultsController?.sections?[section]

        return section?.numberOfObjects ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "earthquakeCell", for: indexPath) as! EarthquakeTableViewCell
        
        if let earthquake = fetchedResultsController?.object(at: indexPath) as? Earthquake {
            cell.configure(earthquake: earthquake)
        }

        return cell
    }
    
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let operation = BlockProcedure {
			DispatchQueue.main.async {
				self.performSegue(withIdentifier: Storyboard.ShowEarthQuake, sender: nil)
			}
        }
        
		operation.add(condition: MutuallyExclusive<UIViewController>())
		
		operation.add(observer: BlockObserver(didFinish: { _, errors in
			DispatchQueue.main.async {
				tableView.deselectRow(at: indexPath, animated: true)
				operation.finish(withErrors: [])
			}
		}))
        procedureQueue.addOperation(operation)
    }
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == Storyboard.ShowEarthQuake {
			guard let detailVC = segue.destination.contentViewController as? EarthquakeTableViewController else { return }
			
			detailVC.procedureQueue = procedureQueue

			if let indexPath = tableView.indexPathForSelectedRow {
				guard let earthquake = fetchedResultsController?.object(at: indexPath) as? Earthquake else { return }
				detailVC.earthquake = earthquake
			}
		}
	}
	    
    private func getEarthquakes(userInitiated: Bool = true) {
        if let context = fetchedResultsController?.managedObjectContext {
            let getEarthquakesOperation = GetLatestEarthquakes(context: context) {
				DispatchQueue.main.async {
                    self.refresh?.endRefreshing()
					self.updateUI()
                }
            }

            getEarthquakesOperation.userIntent = .initiated
            procedureQueue.add(operation: getEarthquakesOperation)
        }
        else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.refresh?.endRefreshing()
            }
        }
    }
    
    func updateUI() {
        do {
            try fetchedResultsController?.performFetch()
            if (self.fetchedResultsController?.fetchedObjects?.count == 0) {
                getEarthquakes()
			} else {
				tableView.reloadData()		
			}
        }
        catch {
            print("Error in the fetched results controller: \(error).")
        }
    }
}
