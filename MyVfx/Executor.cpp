#include "Executor.hpp"

#include <Gfx/GfxApplicationPlugin.hpp>
#include <Gfx/GfxContext.hpp>
#include <Gfx/TexturePort.hpp>
#include <Process/Dataflow/Port.hpp>
#include <Process/ExecutionContext.hpp>

#include <score/document/DocumentContext.hpp>

#include <ossia/dataflow/port.hpp>

#include <MyVfx/Node.hpp>
#include <MyVfx/Process.hpp>
namespace MyVfx
{
class mesh_node final : public Gfx::gfx_exec_node
{
public:
  mesh_node(Gfx::GfxExecutionAction& ctx)
      : gfx_exec_node{ctx}
  {
    root_outputs().push_back(new ossia::texture_outlet);

    auto n = std::make_unique<MyVfx::Node>();

    id = exec_context->ui->register_node(std::move(n));
  }

  ~mesh_node() { exec_context->ui->unregister_node(id); }

  std::string label() const noexcept override { return "MyVfx"; }
};

ProcessExecutorComponent::ProcessExecutorComponent(
    MyVfx::Model& element,
    const Execution::Context& ctx,
    QObject* parent)
    : ProcessComponent_T{element, ctx, "MyVfxExecutorComponent", parent}
{
  try
  {
    auto n = std::make_shared<mesh_node>(
        ctx.doc.plugin<Gfx::DocumentPlugin>().exec);

    this->node = n;
    m_ossia_process = std::make_shared<ossia::node_process>(n);
  }
  catch (...)
  {
  }
}
}
