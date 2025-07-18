package py.com.sodep.academy.jee.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
public class SaludoController {

    @RequestMapping("/saludo")
    public String saludo(Model model) {
        model.addAttribute("mensaje", "¡Hola desde Spring MVC!");
        return "saludo";
    }
}
