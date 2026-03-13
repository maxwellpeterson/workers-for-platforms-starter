import { Context, Hono } from "hono";

type Env = {
  Bindings: {
    APPS: DispatchNamespace;
  };
};

const app = new Hono<Env>();

async function routeToApp(c: Context<Env>) {
  const appName = c.req.param("app")!;
  try {
    const upstream = c.env.APPS.get(appName);
    return await upstream.fetch(c.req.url);
  } catch (error) {
    return c.text("Failed to route to app", 502);
  }
}

app.all("/:app", routeToApp);
app.all("/", (c) => c.text("Missing app name in path", 400));

export default app;
