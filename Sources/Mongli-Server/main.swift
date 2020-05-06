import Kitura
import HeliumLogger

HeliumLogger.use(.error)
HeliumLogger.use(.warning)
let app = App()
app.run()
