package ${{ values.groupId }}.controller;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.RequestMapping;

@CrossOrigin(origins = "*")
@RestController
@RequestMapping("${{ values.apiPrefix }}")
public class ApiController {

    private static final Logger logger = LoggerFactory.getLogger(ApiController.class);

    @GetMapping("/hello")
    public String hello() {
        return "Hello World";
    }
}
