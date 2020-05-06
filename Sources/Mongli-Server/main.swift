import Kitura
import HeliumLogger

HeliumLogger.use(.error)
HeliumLogger.use(.warning)
HeliumLogger.use(.info)
let app = App()
app.run()
